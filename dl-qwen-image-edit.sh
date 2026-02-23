#!/bin/sh

cd /root/workspace/
mkdir -p models/vae models/loras models/text_encoders models/diffusion_models
wget --continue -O models/vae/qwen_image_vae.safetensors https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors
wget --continue -O models/loras/Qwen-Image-Edit-Lightning-4steps-V1.0-bf16.safetensors https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Edit-Lightning-4steps-V1.0-bf16.safetensors
wget --continue -O models/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors
wget --continue -O models/diffusion_models/qwen_image_edit_fp8_e4m3fn.safetensors https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_fp8_e4m3fn.safetensors
