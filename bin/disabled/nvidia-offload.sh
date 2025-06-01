#!/bin/sh

#export LD_PRELOAD="$(find /usr/lib*/opengl/nvidia/lib -name '*.so'  | tr '\n' ' ')"
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0

eval "$@"
