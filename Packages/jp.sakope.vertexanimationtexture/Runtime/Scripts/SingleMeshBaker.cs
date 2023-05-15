using System.Collections.Generic;
using UnityEngine;

namespace VertexAnimationTexture
{
    public class SingleMeshBaker : IMeshBaker
    {
        public List<BakeMeshData> Outputs { get; private set; }
        public SkinnedMeshRenderer[] Renderers { get; }
        public float Length { get; }
        public bool MergedMesh => false;
        public Matrix4x4 RootWorldToLocal { get; private set; } = Matrix4x4.identity;

        private readonly Animation _animation;
        private readonly AnimationState _state;
        private readonly Animator _animator;
        private readonly AnimatorStateInfo _stateInfo;
        private readonly GameObject _targetGameObject;
        private readonly bool _asNewMesh;

        public SingleMeshBaker(GameObject target, bool asNewMesh)
        {
            Outputs = new List<BakeMeshData> { new BakeMeshData() { Mesh = new Mesh(), Transform = target.transform } };
            Renderers = new SkinnedMeshRenderer[Outputs.Count];
            Renderers[0] = target.GetComponentInChildren<SkinnedMeshRenderer>();
            _animation = target.GetComponentInChildren<Animation>();
            _targetGameObject = target;
            _asNewMesh = asNewMesh;

            if (_animation == null)
            {
                _animator = target.GetComponentInChildren<Animator>();
                _stateInfo = _animator.GetCurrentAnimatorStateInfo(0);
                Length = Mathf.Max(Length, _stateInfo.length);
                _animator.PlayInFixedTime(_stateInfo.shortNameHash, 0, 0);
            }
            else
            {
                _state = _animation[_animation.clip.name];
                _state.speed = 0f;
                Length = _state.length;
                _animation.Play(_state.name);
            }
        }

        public void Dispose()
        {
            if (_animator != null) _animator.PlayInFixedTime(_stateInfo.shortNameHash, 0, 0);
            if (_asNewMesh) return;
            foreach (var bakeMeshData in Outputs) bakeMeshData.Dispose();
            Outputs = null;
        }

        public List<BakeMeshData> Sample(float time)
        {
            time = Mathf.Clamp(time, 0f, Length);
            if (_animation == null)
            {
                if (Mathf.Approximately(time, 0))
                {
                    _animator.Update(0);
                    RootWorldToLocal = _targetGameObject.transform.worldToLocalMatrix;
                }
                else
                {
                    _animator.Update(VatBuilder.DT);
                }
            }
            else
            {
                _state.time = time;
                _animation.Sample();
                if (Mathf.Approximately(time, 0)) RootWorldToLocal = _targetGameObject.transform.worldToLocalMatrix;
            }

            Renderers[0].BakeMesh(Outputs[0].Mesh);
            Outputs[0].LocalToWorldMatrix = Renderers[0].localToWorldMatrix;
            Outputs[0].TransposedWorldToLocalMatrix = Renderers[0].worldToLocalMatrix.transpose;
            return Outputs;
        }
    }
}