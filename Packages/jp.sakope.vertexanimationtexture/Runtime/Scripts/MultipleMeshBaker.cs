using System.Collections.Generic;
using UnityEngine;

namespace VertexAnimationTexture
{
    public class MultipleMeshBaker : IMeshBaker
    {
        public List<BakeMeshData> Outputs { get; private set; }
        public SkinnedMeshRenderer[] Renderers { get; }
        public float Length { get; }
        public bool MergedMesh => false;
        public Matrix4x4 RootWorldToLocal { get; private set; } = Matrix4x4.identity;

        private readonly Animation[] _animations;
        private readonly AnimationState[] _state;
        private readonly Animator[] _animators;
        private readonly AnimatorStateInfo[] _stateInfo;
        private readonly GameObject _targetGameObject;
        private readonly bool _asNewMesh;

        public MultipleMeshBaker(GameObject target, bool asNewMesh)
        {
            Renderers = target.GetComponentsInChildren<SkinnedMeshRenderer>();
            Outputs = new List<BakeMeshData>(Renderers.Length);
            _targetGameObject = target;
            _asNewMesh = asNewMesh;

            foreach (var skin in Renderers)
            {
                Outputs.Add(new BakeMeshData() { Mesh = new Mesh(), Transform = skin.gameObject.transform });
            }

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
                _state = new AnimationState[_animations.Length];
                for (var i = 0; i < _animations.Length; i++)
                {
                    var animation = _animations[i];
                    var state = _state[i] = animation[animation.clip.name];
                    state.speed = 0f;
                    Length = Mathf.Max(Length, state.length);
                    animation.Play(state.name);
                }
            }
        }

        public void Dispose()
        {
            if (_animators.Length > 0)
                for(var i = 0; i < _animators.Length; i++) _animators[i].PlayInFixedTime(_stateInfo[i].shortNameHash, 0, 0);
            if (_asNewMesh) return;
            foreach (var bakeMeshData in Outputs) bakeMeshData.Dispose();
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
                    _state[i].time = time;
                    _animations[i].Sample();
                    if (Mathf.Approximately(time, 0)) RootWorldToLocal = _targetGameObject.transform.worldToLocalMatrix;
                }
            }

            for (var i = 0; i < Renderers.Length; i++)
            {
                Renderers[i].BakeMesh(Outputs[i].Mesh);
                Outputs[i].LocalToWorldMatrix = Renderers[i].transform.localToWorldMatrix;
                Outputs[i].TransposedWorldToLocalMatrix = Renderers[i].transform.worldToLocalMatrix.transpose;
            }

            return Outputs;
        }
    }
}