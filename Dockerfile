# ComfyUI Docker Build File v1.0.1 by John Aldred
# https://www.johnaldred.com
# https://github.com/kaouthia

# Use a minimal Python base image (adjust version as needed)
FROM python:3.12-slim-bookworm

# Install OS deps and create the non-root user
RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/*

# Install Mesa/GL and GLib so OpenCV can load libGL.so.1 for ComfyUI-VideoHelperSuite
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libgl1 \
      libglx-mesa0 \
      libglib2.0-0 \
      fonts-dejavu-core \
      fontconfig \
 && rm -rf /var/lib/apt/lists/*

# make ~/.local/bin available on the PATH so scripts like tqdm, torchrun, etc. are found
ENV PATH=/home/appuser/.local/bin:$PATH

# Set the working directory
WORKDIR /app

# Clone the ComfyUI repository (replace URL with the official repo)
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git

# Change directory to the ComfyUI folder
WORKDIR /app/ComfyUI

# Install ComfyUI dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY install-plugin.sh /app
RUN chmod +x /app/install-plugin.sh

RUN mkdir -p /app/ComfyUI/custom_nodes \
 && /app/install-plugin.sh https://github.com/ltdrdata/ComfyUI-Manager.git ComfyUI-Manager \
 && /app/install-plugin.sh https://github.com/cubiq/ComfyUI_essentials.git ComfyUI_essentials \
 && /app/install-plugin.sh https://github.com/crystian/ComfyUI-Crystools.git ComfyUI-Crystools \
 && /app/install-plugin.sh https://github.com/rgthree/rgthree-comfy.git rgthree-comfy \
 && /app/install-plugin.sh https://github.com/kijai/ComfyUI-KJNodes.git ComfyUI-KJNodes \
 && /app/install-plugin.sh https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git ComfyUI_UltimateSDUpscale \
 && /app/install-plugin.sh https://github.com/Acly/comfyui-inpaint-nodes comfyui-inpaint-nodes \
 && /app/install-plugin.sh https://github.com/cubiq/ComfyUI_IPAdapter_plus comfyui_ipadapter_plus \
 && /app/install-plugin.sh https://github.com/1038lab/ComfyUI-JoyCaption/ ComfyUI-JoyCaption \
 && /app/install-plugin.sh https://github.com/un-seen/comfyui_segment_anything_plus comfyui_segment_anything_plus \
 && /app/install-plugin.sh https://github.com/pythongosssss/ComfyUI-WD14-Tagger comfyui-wd14-tagger \
 && pip uninstall -y transformers && pip install -U transformers==4.37 sentence-transformers==2.7.0 \
 && pip cache purge

# Expose the port that ComfyUI will use (change if needed)
EXPOSE 8188

# Copy and enable the startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
 && mkdir -p /app/ComfyUI/user /app/ComfyUI/user/default

# Run entrypoint first, then start ComfyUI
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "/app/ComfyUI/main.py", "--listen", "0.0.0.0", "--lowvram"]
