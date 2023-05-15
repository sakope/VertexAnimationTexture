using System.Collections;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Assertions;

namespace VertexAnimationTexture
{
    [System.Flags]
    public enum CreationModeFlags
    {
        None = 0,
        NewMesh = 1 << 0,
        MergeMesh = 1 << 1,
        UseModelMatrix = 1 << 2,
        IncludeChildComponents = 1 << 3,
    }

    public static class VatAssetsCreator
    {
        public const string DirAssets = "Assets";
        public const string DirRoot = "AnimationTex";

        public static void CreateVertexAnimationTexture(CreationModeFlags flags)
        {
            AssertionCheck(out var selection);
            StartCoroutine(selection, CreateVertexAnimationTexture(selection, flags));
        }

        private static IEnumerator CreateVertexAnimationTexture(GameObject selection, CreationModeFlags flags)
        {
            IMeshBaker meshBaker;

            if (ContainsAllFlags(flags, CreationModeFlags.UseModelMatrix | CreationModeFlags.MergeMesh | CreationModeFlags.IncludeChildComponents))
            {
                meshBaker = new MergeAsLocalMeshBaker(selection, ContainsAllFlags(flags, CreationModeFlags.NewMesh));
            }
            else if (ContainsAllFlags(flags, CreationModeFlags.UseModelMatrix | CreationModeFlags.IncludeChildComponents))
            {
                meshBaker = new MultipleMeshBaker(selection, ContainsAllFlags(flags, CreationModeFlags.NewMesh));
            }
            else if (ContainsAllFlags(flags, CreationModeFlags.MergeMesh | CreationModeFlags.IncludeChildComponents))
            {
                meshBaker = new MergeMeshBaker(selection, ContainsAllFlags(flags, CreationModeFlags.NewMesh));
            }
            else if (ContainsAllFlags(flags, CreationModeFlags.IncludeChildComponents))
            {
                meshBaker = new MultipleMeshBaker(selection, ContainsAllFlags(flags, CreationModeFlags.NewMesh));
            }
            else
            {
                meshBaker = new SingleMeshBaker(selection, ContainsAllFlags(flags, CreationModeFlags.NewMesh));
            }

            var bakeModelMatrix = ContainsAllFlags(flags, CreationModeFlags.UseModelMatrix);

            var vatBuilder = new VatBuilder(meshBaker, bakeModelMatrix);

            var folderPath = AssureExistAndGetRootFolder();
            folderPath = CreateTargetFolder(selection, folderPath);
            yield return 0;

            var gameObject = new GameObject(selection.name);

            for (var i = 0; i < meshBaker.Outputs.Count; i++)
            {
                var posPngPath = folderPath + "/" + meshBaker.Outputs[i].Transform.name + ".png";
                var normPngPath = folderPath + "/" + meshBaker.Outputs[i].Transform.name + "_normal.png";
                var posTex = Save(vatBuilder.PositionTextures[i], posPngPath);
                var normTex = Save(vatBuilder.NormalTextures[i], normPngPath);
                Material mat;

                if (bakeModelMatrix)
                {
                    var modelMatrixPngPath = folderPath + "/" + meshBaker.Outputs[i].Transform.name + "_model.png";
                    var modelMatrixTex = Save(vatBuilder.MatrixTextures[i], modelMatrixPngPath, TextureImporterFormat.RGBA32);
                    mat = CreateMaterial(i, meshBaker, vatBuilder, posTex, normTex, meshBaker.Renderers[i], modelMatrixTex);
                }
                else
                {
                    mat = CreateMaterial(i, meshBaker, vatBuilder, posTex, normTex, meshBaker.Renderers[i]);
                }

                SaveAsset(mat, folderPath + "/" + meshBaker.Outputs[i].Transform.name + ".mat");

                var mesh = meshBaker.Renderers[i].sharedMesh;

                if (ContainsAllFlags(flags, CreationModeFlags.NewMesh))
                {
                    mesh = meshBaker.Outputs[i].Mesh;
                    mesh.bounds = vatBuilder.Bounds(i);
                    SaveAsset(mesh, folderPath + "/" + meshBaker.Outputs[i].Transform.name + ".asset");
                }

                if (meshBaker.Outputs.Count > 1)
                {
                    var child = new GameObject(meshBaker.Outputs[i].Transform.name);
                    child.AddComponent<MeshRenderer>().sharedMaterial = mat;
                    child.AddComponent<MeshFilter>().sharedMesh = mesh;
                    child.transform.parent = gameObject.transform;
                }
                else
                {
                    gameObject.AddComponent<MeshRenderer>().sharedMaterial = mat;
                    gameObject.AddComponent<MeshFilter>().sharedMesh = mesh;
                }
            }

            PrefabUtility.SaveAsPrefabAsset(gameObject, folderPath + "/" + selection.name + ".prefab");

            gameObject.transform.SetPositionAndRotation(selection.transform.position, selection.transform.rotation);
            gameObject.transform.localScale = selection.transform.localScale;

            Object.DestroyImmediate(selection.GetComponent<Dummy>());
            meshBaker.Dispose();
            vatBuilder.Dispose();
        }

        private static void AssertionCheck(out GameObject selection)
        {
            selection = Selection.activeGameObject;
            Assert.IsTrue(selection != null && selection.activeSelf, "Active GameObject is not selected.");
            Assert.IsTrue(selection.GetComponentInChildren<Animation>() || selection.GetComponentInChildren<Animator>(),
                "Animation or Animator component is not found.");
        }

        private static void StartCoroutine(GameObject gameObject, IEnumerator coroutine)
        {
            gameObject.AddComponent<Dummy>().StartCoroutine(coroutine);
        }

        private static void SaveAsset(Object obj, string path)
        {
            AssetDatabase.CreateAsset(obj, path);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        private static string CreateTargetFolder(Object selection, string folderPath)
        {
            var guid = AssetDatabase.CreateFolder(folderPath, selection.name);
            folderPath = AssetDatabase.GUIDToAssetPath(guid);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            return folderPath;
        }

        private static string AssureExistAndGetRootFolder()
        {
            const string folderPath = DirAssets + "/" + DirRoot;
            if (Directory.Exists(folderPath)) return folderPath;
            AssetDatabase.CreateFolder(DirAssets, DirRoot);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            return folderPath;
        }

        private static Material CreateMaterial(int meshId, IMeshBaker meshBaker, VatBuilder vatBuilder,
            Texture posTex = null, Texture normTex = null, Renderer renderer = null, Texture2D modelTex = null)
        {
            Material mat;
            if (modelTex)
                mat = meshBaker.MergedMesh ? new Material(Shader.Find(ShaderConst.UseMergedMatrixShaderName)) : new Material(Shader.Find(ShaderConst.UseMatrixShaderName));
            else
                mat = new Material(Shader.Find(ShaderConst.ShaderName));
            if (renderer != null && renderer.sharedMaterial != null) mat.mainTexture = renderer.sharedMaterial.mainTexture;
            if (posTex != null) mat.SetTexture(ShaderConst.AnimTex, posTex); 
            mat.SetVector(ShaderConst.Scale, vatBuilder.Scales[meshId]);
            mat.SetVector(ShaderConst.Offset, vatBuilder.Offsets[meshId]);
            mat.SetVector(ShaderConst.AnimEnd, new Vector4(meshBaker.Length, vatBuilder.VerticesList[meshId].Count - 1, 0f, 0f));
            mat.SetFloat(ShaderConst.Fps, VatBuilder.Fps);
            if (normTex != null) mat.SetTexture(ShaderConst.NormTex, normTex);
            if (modelTex == null) return mat;
            mat.SetTexture(ShaderConst.ModelTex, modelTex);
            mat.SetFloat(ShaderConst.LocalToWorldScale, vatBuilder.LocalToWorldScales[meshId]);
            mat.SetFloat(ShaderConst.LocalToWorldOffset, vatBuilder.LocalToWorldOffsets[meshId]);
            mat.SetFloat(ShaderConst.TransposedWorldToLocalScale, vatBuilder.TransposedWorldToLocalScales[meshId]);
            mat.SetFloat(ShaderConst.TransposedWorldToLocalOffset, vatBuilder.TransposedWorldToLocalOffsets[meshId]);
            return mat;
        }

        private static Texture2D Save(Texture2D tex, string pngPath, TextureImporterFormat texFormat = TextureImporterFormat.RGB24)
        {
#if UNITY_5_5_OR_NEWER
            File.WriteAllBytes(pngPath, tex.EncodeToPNG());
            AssetDatabase.ImportAsset(pngPath, ImportAssetOptions.ForceUpdate);
            var pngImporter = (TextureImporter)AssetImporter.GetAtPath(pngPath);
            var pngSettings = new TextureImporterSettings();
            pngImporter.ReadTextureSettings(pngSettings);
            pngSettings.filterMode = VatBuilder.VatFilterMode;
            pngSettings.mipmapEnabled = false;
            pngSettings.sRGBTexture = false;
            pngSettings.wrapMode = TextureWrapMode.Clamp;
            pngImporter.SetTextureSettings(pngSettings);
            var platformSettings = pngImporter.GetDefaultPlatformTextureSettings();
            platformSettings.format = texFormat;
            platformSettings.maxTextureSize = Mathf.Max(platformSettings.maxTextureSize, Mathf.Max(tex.width, tex.height));
            platformSettings.textureCompression = TextureImporterCompression.Uncompressed;
            pngImporter.SetPlatformTextureSettings(platformSettings);
            AssetDatabase.WriteImportSettingsIfDirty(pngPath);
            AssetDatabase.ImportAsset(pngPath, ImportAssetOptions.ForceUpdate);

#else
            File.WriteAllBytes (pngPath, tex.EncodeToPNG ());
            AssetDatabase.ImportAsset (pngPath, ImportAssetOptions.ForceUpdate);
            var pngImporter = (TextureImporter)AssetImporter.GetAtPath (pngPath);
            var pngSettings = new TextureImporterSettings ();
            pngImporter.ReadTextureSettings (pngSettings);
            pngSettings.filterMode = ANIM_TEX_FILTER;
            pngSettings.mipmapEnabled = false;
            pngSettings.linearTexture = true;
            pngSettings.wrapMode = TextureWrapMode.Clamp;
            pngImporter.SetTextureSettings (pngSettings);
            pngImporter.textureFormat = TextureImporterFormat.RGB24;
            pngImporter.maxTextureSize = Mathf.Max (pngImporter.maxTextureSize, Mathf.Max (tex.width, tex.height));
            pngImporter.SaveAndReimport();
            //AssetDatabase.WriteImportSettingsIfDirty (pngPath);
            //AssetDatabase.ImportAsset (pngPath, ImportAssetOptions.ForceUpdate);
#endif

            return (Texture2D)AssetDatabase.LoadAssetAtPath(pngPath, typeof(Texture2D));
        }

        private static bool ContainsAllFlags(CreationModeFlags flags, CreationModeFlags contains)
        {
            return (flags & contains) == contains;
        }
    }
}