using System.Collections.Generic;
using UnityEngine;

namespace VertexAnimationTexture
{
    public interface IMeshBaker : System.IDisposable
    {
        List<BakeMeshData> Outputs { get; }
        SkinnedMeshRenderer[] Renderers { get; }
        float Length { get; }
        bool MergedMesh { get; }
        Matrix4x4 RootWorldToLocal { get; }
        List<BakeMeshData> Sample(float time);
    }
}