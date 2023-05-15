using System.Linq;
using System.Collections.Generic;
using UnityEngine;

namespace VertexAnimationTexture
{
    public class VatBuilder : System.IDisposable
    {
        public const float Fps = 5f;
        public const FilterMode VatFilterMode = FilterMode.Bilinear;

        public const float DT = 1f / Fps;
        public const float ColorDepth = 255f;
        public const float ColorDepthInvert = 1f / ColorDepth;

        public readonly List<Vector4> Scales = new List<Vector4>();
        public readonly List<Vector4> Offsets = new List<Vector4>();
        public readonly List<float> LocalToWorldScales = new List<float>();
        public readonly List<float> LocalToWorldOffsets = new List<float>();
        public readonly List<float> TransposedWorldToLocalScales = new List<float>();
        public readonly List<float> TransposedWorldToLocalOffsets = new List<float>();
        public readonly List<Texture2D> PositionTextures = new List<Texture2D>();
        public readonly List<Texture2D> NormalTextures = new List<Texture2D>();
        public readonly List<Texture2D> MatrixTextures = new List<Texture2D>();
        public readonly List<List<Vector3[]>> VerticesList = new List<List<Vector3[]>>();
        public readonly List<List<Vector3[]>> NormalsList = new List<List<Vector3[]>>();
        public readonly List<List<Matrix4x4>> LocalToWorldTensor = new List<List<Matrix4x4>>();
        public readonly List<List<Matrix4x4>> TransposedWorldToLocalTensor = new List<List<Matrix4x4>>();

        private readonly List<float> _frameEnds = new List<float>();
        private readonly List<Vector2[]> _uv2 = new List<Vector2[]>();

        public VatBuilder(IMeshBaker sample, bool createModelTexture)
        {
            var outputCount = sample.Outputs.Count;

            for (var i = 0; i < outputCount; i++)
            {
                VerticesList.Add(new List<Vector3[]>());
                NormalsList.Add(new List<Vector3[]>());
                if (!createModelTexture) continue;
                if (sample.MergedMesh) continue;
                LocalToWorldTensor.Add(new List<Matrix4x4>());
                TransposedWorldToLocalTensor.Add(new List<Matrix4x4>());
            }

            if (createModelTexture && sample.MergedMesh)
            {
                for (var i = 0; i < sample.Renderers.Length; i++)
                {
                    LocalToWorldTensor.Add(new List<Matrix4x4>());
                    TransposedWorldToLocalTensor.Add(new List<Matrix4x4>());
                }
            }

            for (float t = 0; t < (sample.Length + DT); t += DT)
            {
                var bakeMeshData = sample.Sample(t);
                for (var i = 0; i < outputCount; i++)
                {
                    var vertices = bakeMeshData[i].Mesh.vertices;
                    var normals = bakeMeshData[i].Mesh.normals;

                    if (createModelTexture)
                    {
                        if (!sample.MergedMesh)
                        {
                            LocalToWorldTensor[i].Add(sample.RootWorldToLocal * bakeMeshData[i].LocalToWorldMatrix);
                            TransposedWorldToLocalTensor[i].Add(sample.RootWorldToLocal * bakeMeshData[i].TransposedWorldToLocalMatrix);
                        }
                    }
                    else
                    {
                        //multiple world mesh and single mesh.
                        for (var j = 0; j < vertices.Length; j++)
                        {
                            vertices[j] = sample.RootWorldToLocal * bakeMeshData[i].LocalToWorldMatrix.MultiplyPoint3x4(vertices[j]);
                            normals[j] = sample.RootWorldToLocal * bakeMeshData[i].TransposedWorldToLocalMatrix.MultiplyVector(normals[j]);
                        }
                    }

                    VerticesList[i].Add(vertices);
                    NormalsList[i].Add(normals);
                }

                if (!createModelTexture || !sample.MergedMesh) continue;

                for (var i = 0; i < sample.Renderers.Length; i++)
                {
                    LocalToWorldTensor[i].Add(sample.RootWorldToLocal * sample.Renderers[i].transform.localToWorldMatrix);
                    TransposedWorldToLocalTensor[i].Add(sample.RootWorldToLocal * sample.Renderers[i].transform.worldToLocalMatrix.transpose);
                }
            }

            for (var i = 0; i < outputCount; i++)
            {
                var firstVertices = VerticesList[i][0];
                var firstVertex = firstVertices[0];
                var vertexCount = firstVertices.Length;
                _frameEnds.Add(vertexCount - 1);

                var minX = firstVertex.x;
                var minY = firstVertex.y;
                var minZ = firstVertex.z;
                var maxX = firstVertex.x;
                var maxY = firstVertex.y;
                var maxZ = firstVertex.z;
                foreach (var v in VerticesList[i].SelectMany(vertices => vertices))
                {
                    minX = Mathf.Min(minX, v.x);
                    minY = Mathf.Min(minY, v.y);
                    minZ = Mathf.Min(minZ, v.z);
                    maxX = Mathf.Max(maxX, v.x);
                    maxY = Mathf.Max(maxY, v.y);
                    maxZ = Mathf.Max(maxZ, v.z);
                }
                Scales.Add(new Vector4(maxX - minX, maxY - minY, maxZ - minZ, 1f));
                Offsets.Add(new Vector4(minX, minY, minZ, 1f));
                Debug.LogFormat("Scale={0} Offset={1}", Scales[i], Offsets[i]);

                var texWidth = LargerInPow2(vertexCount);
                var texHeight = LargerInPow2(VerticesList[i].Count * 2);
                Debug.Log($"tex({texWidth}x{texHeight}), nVertices={vertexCount} nFrames={VerticesList[i].Count}");

                PositionTextures.Add(new Texture2D(texWidth, texHeight, TextureFormat.RGB24, false, true));
                PositionTextures[i].filterMode = VatFilterMode;
                PositionTextures[i].wrapMode = TextureWrapMode.Clamp;

                NormalTextures.Add(new Texture2D(texWidth, texHeight, TextureFormat.RGB24, false, true));
                NormalTextures[i].filterMode = VatFilterMode;
                NormalTextures[i].wrapMode = TextureWrapMode.Clamp;

                _uv2.Add(new Vector2[vertexCount]);
                var texSize = new Vector2(1f / texWidth, 1f / texHeight);
                var halfTexOffset = 0.5f * texSize;
                for (var j = 0; j < _uv2[i].Length; j++)
                    _uv2[i][j] = new Vector2((float)j * texSize.x, 0f) + halfTexOffset;
                for (var y = 0; y < VerticesList[i].Count; y++)
                {
                    var vertices = VerticesList[i][y];
                    var normals = NormalsList[i][y];
                    for (var x = 0; x < vertices.Length; x++)
                    {
                        var pos = Normalize(vertices[x], Offsets[i], Scales[i]);
                        Color c0, c1;
                        Encode(pos, out c0, out c1);
                        PositionTextures[i].SetPixel(x, y, c0);
                        PositionTextures[i].SetPixel(x, y + (texHeight >> 1), c1);

                        var normal = 0.5f * (normals[x].normalized + Vector3.one);
                        Encode(normal, out c0, out c1);
                        NormalTextures[i].SetPixel(x, y, c0);
                        NormalTextures[i].SetPixel(x, y + (texHeight >> 1), c1);
                    }
                }
                PositionTextures[i].Apply();
                NormalTextures[i].Apply();

                if (!createModelTexture) continue;
                if (sample.MergedMesh) continue;

                var firstFrameOfLocalToWorld = LocalToWorldTensor[i][0];
                var minElementOfLocalToWorld = firstFrameOfLocalToWorld[0, 0];
                var maxElementOfLocalToWorld = firstFrameOfLocalToWorld[0, 0];
                var firstFrameOfTransposedWorldToLocal = TransposedWorldToLocalTensor[i][0];
                var minElementOfTransposedWorldToLocal = firstFrameOfTransposedWorldToLocal[0, 0];
                var maxElementOfTransposedWorldToLocal = firstFrameOfTransposedWorldToLocal[0, 0];
                for (var j = 0; j < LocalToWorldTensor[i].Count; j++)
                {
                    for (var r = 0; r < 4; r++)
                    {
                        for (var c = 0; c < 4; c++)
                        {
                            minElementOfLocalToWorld = Mathf.Min(minElementOfLocalToWorld, LocalToWorldTensor[i][j][r, c]);
                            maxElementOfLocalToWorld = Mathf.Max(maxElementOfLocalToWorld, LocalToWorldTensor[i][j][r, c]);
                            minElementOfTransposedWorldToLocal = Mathf.Min(minElementOfTransposedWorldToLocal, TransposedWorldToLocalTensor[i][j][r, c]);
                            maxElementOfTransposedWorldToLocal = Mathf.Max(maxElementOfTransposedWorldToLocal, TransposedWorldToLocalTensor[i][j][r, c]);
                        }
                    }
                }
                LocalToWorldScales.Add(maxElementOfLocalToWorld - minElementOfLocalToWorld);
                LocalToWorldOffsets.Add(minElementOfLocalToWorld);
                TransposedWorldToLocalScales.Add(maxElementOfTransposedWorldToLocal - minElementOfTransposedWorldToLocal);
                TransposedWorldToLocalOffsets.Add(minElementOfTransposedWorldToLocal);

                MatrixTextures.Add(new Texture2D(8, texHeight, TextureFormat.RGBA32, false, true));
                MatrixTextures[i].filterMode = VatFilterMode;
                MatrixTextures[i].wrapMode = TextureWrapMode.Clamp;

                for (var y = 0; y < VerticesList[i].Count; y++)
                {
                    var eachFrameOfLocalToWorld = LocalToWorldTensor[i][y];
                    var eachFrameOfTransposedWorldToLocal = TransposedWorldToLocalTensor[i][y];
                    for (var c = 0; c < 4; c++)
                    {
                        var localToWorldColumnVector = Normalize(eachFrameOfLocalToWorld.GetColumn(c), LocalToWorldOffsets[i], LocalToWorldScales[i]);
                        Color c0, c1;
                        Encode(localToWorldColumnVector, out c0, out c1);
                        MatrixTextures[i].SetPixel(c, y, c0);
                        MatrixTextures[i].SetPixel(c, y + (texHeight >> 1), c1);

                        var transposedWorldToLocalColumnVector = Normalize(eachFrameOfTransposedWorldToLocal.GetColumn(c), TransposedWorldToLocalOffsets[i], TransposedWorldToLocalScales[i]);
                        Encode(transposedWorldToLocalColumnVector, out c0, out c1);
                        MatrixTextures[i].SetPixel(c + 4, y, c0);
                        MatrixTextures[i].SetPixel(c + 4, y + (texHeight >> 1), c1);
                    }
                }
                MatrixTextures[i].Apply();
            }

            if (createModelTexture && sample.MergedMesh)
            {
                var firstFrameOfLocalToWorld = LocalToWorldTensor[0][0];
                var minElementOfLocalToWorld = firstFrameOfLocalToWorld[0, 0];
                var maxElementOfLocalToWorld = firstFrameOfLocalToWorld[0, 0];
                var firstFrameOfTransposedWorldToLocal = TransposedWorldToLocalTensor[0][0];
                var minElementOfTransposedWorldToLocal = firstFrameOfTransposedWorldToLocal[0, 0];
                var maxElementOfTransposedWorldToLocal = firstFrameOfTransposedWorldToLocal[0, 0];
                for (var i = 0; i < sample.Renderers.Length; i++)
                {
                    for (var j = 0; j < LocalToWorldTensor[i].Count; j++)
                    {
                        for (var r = 0; r < 4; r++)
                        {
                            for (var c = 0; c < 4; c++)
                            {
                                minElementOfLocalToWorld = Mathf.Min(minElementOfLocalToWorld, LocalToWorldTensor[i][j][r, c]);
                                maxElementOfLocalToWorld = Mathf.Max(maxElementOfLocalToWorld, LocalToWorldTensor[i][j][r, c]);
                                minElementOfTransposedWorldToLocal = Mathf.Min(minElementOfTransposedWorldToLocal, TransposedWorldToLocalTensor[i][j][r, c]);
                                maxElementOfTransposedWorldToLocal = Mathf.Max(maxElementOfTransposedWorldToLocal, TransposedWorldToLocalTensor[i][j][r, c]);
                            }
                        }
                    }
                }
                LocalToWorldScales.Add(maxElementOfLocalToWorld - minElementOfLocalToWorld);
                LocalToWorldOffsets.Add(minElementOfLocalToWorld);
                TransposedWorldToLocalScales.Add(maxElementOfTransposedWorldToLocal - minElementOfTransposedWorldToLocal);
                TransposedWorldToLocalOffsets.Add(minElementOfTransposedWorldToLocal);

                var texWidth = LargerInPow2(8 * sample.Renderers.Length);
                var texHeight = LargerInPow2(VerticesList[0].Count * 2);
                MatrixTextures.Add(new Texture2D(texWidth, texHeight, TextureFormat.RGBA32, false, true));
                MatrixTextures[0].filterMode = VatFilterMode;
                MatrixTextures[0].wrapMode = TextureWrapMode.Clamp;

                for (var i = 0; i < sample.Renderers.Length; i++)
                {
                    for (var y = 0; y < VerticesList[0].Count; y++)
                    {
                        var eachFrameOfLocalToWorld = LocalToWorldTensor[i][y];
                        var eachFrameOfTransposedWorldToLocal = TransposedWorldToLocalTensor[i][y];
                        for (var c = 0; c < 4; c++)
                        {
                            var localToWorldColumnVector = Normalize(
                                eachFrameOfLocalToWorld.GetColumn(c), LocalToWorldOffsets[0], LocalToWorldScales[0]);
                            Color c0, c1;
                            Encode(localToWorldColumnVector, out c0, out c1);
                            MatrixTextures[0].SetPixel(c + (i * 8), y, c0);
                            MatrixTextures[0].SetPixel(c + (i * 8), y + (texHeight >> 1), c1);

                            var transposedWorldToLocalColumnVector = Normalize(
                                eachFrameOfTransposedWorldToLocal.GetColumn(c), TransposedWorldToLocalOffsets[0], TransposedWorldToLocalScales[0]);
                            Encode(transposedWorldToLocalColumnVector, out c0, out c1);
                            MatrixTextures[0].SetPixel(c + 4 + (i * 8), y, c0);
                            MatrixTextures[0].SetPixel(c + 4 + (i * 8), y + (texHeight >> 1), c1);
                        }
                    }
                }

                MatrixTextures[0].Apply();
            }
        }

        public Vector3 Position(int meshId, int vid, float frame)
        {
            frame = Mathf.Clamp(frame, 0f, _frameEnds[meshId]);
            var uv = _uv2[meshId][vid];
            uv.y += frame * PositionTextures[meshId].texelSize.y;
            var pos1 = PositionTextures[meshId].GetPixelBilinear(uv.x, uv.y);
            var pos2 = PositionTextures[meshId].GetPixelBilinear(uv.x, uv.y + 0.5f);
            return new Vector3(
                (pos1.r + pos2.r / ColorDepth) * Scales[meshId].x + Offsets[meshId].x,
                (pos1.g + pos2.g / ColorDepth) * Scales[meshId].y + Offsets[meshId].y,
                (pos1.b + pos2.b / ColorDepth) * Scales[meshId].z + Offsets[meshId].z);
        }

        public Bounds Bounds(int meshId) { return new Bounds((Vector3)(0.5f * Scales[meshId] + Offsets[meshId]), (Vector3)Scales[meshId]); }

        public Vector3[] Vertices(int meshId, float frame)
        {
            frame = Mathf.Clamp(frame, 0f, _frameEnds[meshId]);
            var index = Mathf.Clamp((int)frame, 0, VerticesList[meshId].Count - 1);
            var vertices = VerticesList[meshId][index];
            return vertices;
        }

        private static Vector3 Normalize(Vector3 pos, Vector3 offset, Vector3 scale)
        {
            return new Vector3(
                (pos.x - offset.x) / scale.x,
                (pos.y - offset.y) / scale.y,
                (pos.z - offset.z) / scale.z);
        }

        private static Vector4 Normalize(Vector4 v, float offset, float scale)
        {
            return new Vector4(
                (v.x - offset),
                (v.y - offset),
                (v.z - offset),
                (v.w - offset)) / scale;
        }

        private static void Encode(float v01, out float c0, out float c1)
        {
            c0 = Mathf.Clamp01(Mathf.Floor(v01 * ColorDepth) * ColorDepthInvert);
            c1 = Mathf.Clamp01(Mathf.Round((v01 - c0) * ColorDepth * ColorDepth) * ColorDepthInvert);
        }

        private static void Encode(Vector3 v01, out Color c0, out Color c1)
        {
            float c0x, c0y, c0z, c1x, c1y, c1z;
            Encode(v01.x, out c0x, out c1x);
            Encode(v01.y, out c0y, out c1y);
            Encode(v01.z, out c0z, out c1z);
            c0 = new Color(c0x, c0y, c0z, 1f);
            c1 = new Color(c1x, c1y, c1z, 1f);
        }

        private static void Encode(Vector4 v01, out Color c0, out Color c1)
        {
            float c0x, c0y, c0z, c0w, c1x, c1y, c1z, c1w;
            Encode(v01.x, out c0x, out c1x);
            Encode(v01.y, out c0y, out c1y);
            Encode(v01.z, out c0z, out c1z);
            Encode(v01.w, out c0w, out c1w);
            c0 = new Color(c0x, c0y, c0z, c0w);
            c1 = new Color(c1x, c1y, c1z, c1w);
        }

        private static int LargerInPow2(int width)
        {
            width--;
            var digits = 0;
            while (width > 0)
            {
                width >>= 1;
                digits++;
            }
            return 1 << digits;
        }

        #region IDisposable implementation
        public void Dispose()
        {
            PositionTextures.ForEach(t => Object.DestroyImmediate(t));
            NormalTextures.ForEach(t => Object.DestroyImmediate(t));
            MatrixTextures.ForEach(t => Object.DestroyImmediate(t));
            PositionTextures.Clear();
            NormalTextures.Clear();
            MatrixTextures.Clear();
        }
        #endregion
    }
}
