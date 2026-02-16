 Вариант для вставки в ComfyUI-to-API (Step 3). База + все ноды и модели под твой workflow.

# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.7.1-base

# install custom nodes (MaskBlur+, MaskPreview+ из сгенерированного + Segment Anything 2)
RUN comfy node install --exit-on-fail MaskBlur+ --mode remote
RUN comfy node install --exit-on-fail MaskPreview+
RUN comfy-node-install ComfyUI-segment-anything-2

# Aria2 для быстрой загрузки моделей
RUN apt-get update && apt-get install -y --no-install-recommends aria2 \
  && rm -rf /var/lib/apt/lists/*

# Чекпоинт agfluxFillNSFWFp8 (CivitAI)
RUN aria2c -x 16 -s 16 -d /comfyui/models/checkpoints -o agfluxFillNSFWFp8_agfluxFillNSFWV17Fp8.safetensors \
  "https://civitai.com/api/download/models/1095910?type=Model&format=SafeTensor&size=full&fp=fp8"

# VAE для FLUX
RUN aria2c -x 16 -s 16 -d /comfyui/models/vae -o ae.safetensors \
  "https://huggingface.co/flux-safetensors/flux-safetensors/resolve/main/ae.safetensors"

# CLIP для FLUX (clip_l + t5xxl_fp8) — в models/clip, как в твоём workflow
RUN aria2c -x 16 -s 16 -d /comfyui/models/clip -o clip_l.safetensors \
  "https://huggingface.co/flux-safetensors/flux-safetensors/resolve/main/clip_l.safetensors"
RUN aria2c -x 16 -s 16 -d /comfyui/models/clip -o t5xxl_fp8_e4m3fn.safetensors \
  "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors"

# Модели SAM2 нода ComfyUI-segment-anything-2 обычно подтягивает при первом запуске
# или скачиваются из репозитория ноды. При необходимости добавь RUN с прямыми URL из документации ноды.
