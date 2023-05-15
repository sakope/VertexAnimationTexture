using System;
using UnityEngine;
using UnityEditor;

namespace VertexAnimationTexture
{
    public class VatEditor : EditorWindow
    {
        private enum BakeCoordinate
        {
            LocalCoordAndModelMatrix,
            WorldCoord
        }

        private enum MeshCreation
        {
            MergeMesh,
            ReuseMesh,
            NewMesh,
        }

        private BakeCoordinate _bakeCoordinate = BakeCoordinate.LocalCoordAndModelMatrix;
        private MeshCreation _meshCreation = MeshCreation.MergeMesh;
        private static Vector2 _popupPosition;
        private string _errorMessage;

        private const float WindowWidth = 380f, WindowHeight = 115f, Margin = 8f;

        [MenuItem("Window/Vertex Animation Texture")]
        private static void Window()
        {
            var window = CreateInstance<VatEditor>();
            window.titleContent = new GUIContent("Create VAT");
            window.position = new Rect(_popupPosition, new Vector2(WindowWidth, WindowHeight));
            window.ShowUtility();
        }

        private void OnGUI()
        {
            EditorGUILayout.Space(Margin);
            _popupPosition = GUIUtility.GUIToScreenPoint(Event.current.mousePosition);
            _bakeCoordinate = (BakeCoordinate) EditorGUILayout.EnumPopup("Bake coordinate", _bakeCoordinate);
            _meshCreation = (MeshCreation) EditorGUILayout.EnumPopup("Mesh export", _meshCreation);
            EditorGUILayout.Space(Margin);

            if (!string.IsNullOrEmpty(_errorMessage))
            {
                GUILayout.Label(_errorMessage);
                EditorGUILayout.Space(Margin);
            }

            if (!GUILayout.Button("Bake!!")) return;

            if (!AssertionCheck(Selection.activeGameObject)) return;

            Close();

            CreationModeFlags flag;

            switch (_bakeCoordinate, _meshCreation)
            {
                case (BakeCoordinate.LocalCoordAndModelMatrix, MeshCreation.MergeMesh):
                    flag = CreationModeFlags.UseModelMatrix | CreationModeFlags.MergeMesh | CreationModeFlags.IncludeChildComponents | CreationModeFlags.NewMesh;
                    break;
                case (BakeCoordinate.LocalCoordAndModelMatrix, MeshCreation.NewMesh):
                    flag = CreationModeFlags.UseModelMatrix | CreationModeFlags.NewMesh | CreationModeFlags.IncludeChildComponents;
                    break;
                case (BakeCoordinate.LocalCoordAndModelMatrix, MeshCreation.ReuseMesh):
                    flag = CreationModeFlags.UseModelMatrix | CreationModeFlags.IncludeChildComponents;
                    break;
                case (BakeCoordinate.WorldCoord, MeshCreation.MergeMesh):
                    flag = CreationModeFlags.UseModelMatrix | CreationModeFlags.MergeMesh | CreationModeFlags.IncludeChildComponents | CreationModeFlags.NewMesh;
                    break;
                case (BakeCoordinate.WorldCoord, MeshCreation.NewMesh):
                    flag = CreationModeFlags.NewMesh | CreationModeFlags.IncludeChildComponents;
                    break;
                case (BakeCoordinate.WorldCoord, MeshCreation.ReuseMesh):
                    flag = CreationModeFlags.IncludeChildComponents;
                    break;
                case (_, _):
                    throw new ArgumentOutOfRangeException();
            }

            VatAssetsCreator.CreateVertexAnimationTexture(flag);
        }

        private bool AssertionCheck(GameObject selection)
        {
            if (selection == null || !selection.activeSelf)
            {
                _errorMessage = "Active GameObject is not selected.";
                return false;
            }

            if (!selection.GetComponentInChildren<Animation>() && !selection.GetComponentInChildren<Animator>())
            {
                _errorMessage = "Animation or Animator component is not found.";
                return false;
            }

            _errorMessage = "";
            return true;
        }
    }
}