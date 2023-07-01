# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- Add ShaderGraph sample files for URP/HDRP.

## [1.0.1] - 2023-07-01
### Changed
- Changed hlsl normal matrix operation from 4x4 matrix to 3x3 matrix to improve performance.

### Fixed
- A shader function with the same name Inverse existed in Common.hlsl in com.unity.render-pipeline.core. The function name has been changed to avoid redefinition errors when selecting pipelines such as URP.

## [1.0.0] - 2023-05-15
### Added
- First release.
