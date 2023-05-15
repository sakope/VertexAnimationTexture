using System.Collections.Generic;
using UnityEngine;

namespace VertexAnimationTexture
{
    public class MergeMeshBaker : IMeshBaker
    {
        public List<BakeMeshData> Outputs { get; private set; }
        public SkinnedMeshRenderer[] Renderers { get; }
        public float Length { get; }
        public bool MergedMesh => true;
        public Matrix4x4 RootWorldToLocal { get; private set; } = Matrix4x4.identity;

        private readonly Animation[] _animations;
        private readonly AnimationState[] _states;
        private readonly Animator[] _animators;
        private readonly AnimatorStateInfo[] _stateInfo;
        private readonly GameObject _targetGameObject;
        private readonly bool _ssNewMesh;

        private Mesh[] _meshes;

        public MergeMeshBaker(GameObject target, bool asNewMesh)
        {
            Outputs = new List<BakeMeshData> { new BakeMeshData() { Mesh = new Mesh(), Transform = target.transform } };
            Renderers = target.GetComponentsInChildren<SkinnedMeshRenderer>();
            _targetGameObject = target;
            _ssNewMesh = asNewMesh;
            _meshes = new Mesh[Renderers.Length];

            for (var i = 0; i < Renderers.Length; i++) _meshes[i] = new Mesh();

            _animators = target.GetComponentsInChildren<Animator>();

            if (_animators.Length > 0)
            {
                _animators = target.GetComponentsInChildren<Animator>();
                _stateInfo = new AnimatorStateInfo[_animators.Length];
                for (var i = 0; i < _animators.Length; i++)
                {
                    _stateInfo[i] = _animators[i].GetCurrentAnimatorStateInfo(0);
                    Length = Mathf.Max(Length, _stateInfo[i].length);
                    _animators[i].PlayInFixedTime(_stateInfo[i].shortNameHash, 0, 0);
                }
            }
            else
            {
                _animations = target.GetComponentsInChildren<Animation>();
                _states = new AnimationState[_animations.Length];
                for (var i = 0; i < _animations.Length; i++)
                {
                    var animation = _animations[i];
                    var state = _states[i] = animation[animation.clip.name];
                    state.speed = 0f;
                    Length = Mathf.Max(Length, state.length);
                    animation.Play(state.name);
                }
            }
        }

        public void Dispose()
        {
            Debug.Log("Dispose temporary meshes");
            if (_animators.Length > 0)
            {
                for (var i = 0; i < _animators.Length; i++) _animators[i].PlayInFixedTime(_stateInfo[i].shortNameHash, 0, 0);
            }
            foreach (var mesh in _meshes) Object.DestroyImmediate(mesh);
            if (_ssNewMesh) return;
            foreach (var bakeMeshData in Outputs) bakeMeshData.Dispose();
            _meshes = null;
            Outputs = null;
        }

        public List<BakeMeshData> Sample(float time)
        {
            time = Mathf.Clamp(time, 0f, Length);

            if (_animators.Length > 0)
            {
                if (Mathf.Approximately(time, 0))
                {
                    foreach (var animator in _animators) animator.Update(0);
                    RootWorldToLocal = _targetGameObject.transform.worldToLocalMatrix;
                }
                else
                {
                    foreach (var animator in _animators) animator.Update(VatBuilder.DT);
                }
            }
            else
            {
                for (var i = 0; i < _animations.Length; i++)
                {
                    _states[i].time = time;
                    _animations[i].Sample();
                    if (Mathf.Approximately(time, 0)) RootWorldToLocal = _targetGameObject.transform.worldToLocalMatrix;
                }
            }

            var combines = new CombineInstance[_meshes.Length];
            for (var i = 0; i < Renderers.Length; i++)
            {
                var skin = Renderers[i];
                var mesh = _meshes[i];
                var combine = combines[i];
                skin.BakeMesh(mesh);

                var vertices = mesh.vertices;
                var uvForMeshIndex = new Vector2[vertices.Length];
                for (var j = 0; j < uvForMeshIndex.Length; j++)
                {
                    uvForMeshIndex[j] = new Vector2(i, 0);
                }
                mesh.SetUVs(4, uvForMeshIndex);

                combine.mesh = mesh;
                combine.transform = skin.transform.localToWorldMatrix;
                combines[i] = combine;
            }

            Outputs[0].Mesh.CombineMeshes(combines);
            return Outputs;
        }
    }
}