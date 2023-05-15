using UnityEngine;

namespace VertexAnimationTexture
{
    public static class ShaderConst
    {
        public static readonly string ShaderName = "VertexAnimation/WorldCoord/NormalVisualizer";
        public static readonly string UseMatrixShaderName = "VertexAnimation/LocalCoord_Matrix/NormalVisualizer";
        public static readonly string UseMergedMatrixShaderName = "VertexAnimation/LocalCoord_Matrix_MergedMesh/NormalVisualizer";

        public static readonly int AnimTex = Shader.PropertyToID("_VertAnimTex");
        public static readonly int NormTex = Shader.PropertyToID("_NormalAnimTex");
        public static readonly int Scale = Shader.PropertyToID("_VertAnimTex_Scale");
        public static readonly int Offset = Shader.PropertyToID("_VertAnimTex_Offset");
        public static readonly int AnimEnd = Shader.PropertyToID("_AnimTex_AnimEnd");
        public static readonly int Fps = Shader.PropertyToID("_AnimTex_FPS");
        public static readonly int ModelTex = Shader.PropertyToID("_MatrixAnimTex");
        public static readonly int LocalToWorldScale = Shader.PropertyToID("_MatrixAnimTex_M_Scale");
        public static readonly int LocalToWorldOffset = Shader.PropertyToID("_MatrixAnimTex_M_Offset");
        public static readonly int TransposedWorldToLocalScale = Shader.PropertyToID("_MatrixAnimTex_IT_M_Scale");
        public static readonly int TransposedWorldToLocalOffset = Shader.PropertyToID("_MatrixAnimTex_IT_M_Offset");
    }
}
