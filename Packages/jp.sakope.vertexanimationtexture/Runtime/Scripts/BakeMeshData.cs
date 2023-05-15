using System.Collections;
using UnityEngine;

namespace VertexAnimationTexture
{
    public class BakeMeshData : System.IDisposable
    {
        public Mesh Mesh;
        public Matrix4x4 LocalToWorldMatrix = Matrix4x4.identity;
        public Matrix4x4 TransposedWorldToLocalMatrix = Matrix4x4.identity;
        public Transform Transform;

        public void Dispose()
        {
            Debug.Log("Dispose Mesh Data");
            Object.DestroyImmediate(Mesh);
        }
    }
}