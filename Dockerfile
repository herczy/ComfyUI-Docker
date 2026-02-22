# ComfyUI Docker Build File v1.0.1 by John Aldred
# https://www.johnaldred.com
# https://github.com/kaouthia

# Use a minimal Python base image (adjust version as needed)
FROM vastai/base-image:cuda-13.1.0-auto

# Allow passing in your host UID/GID (defaults 1000:1000)
ARG UID=1000
ARG GID=1000

# make ~/.local/bin available on the PATH so scripts like tqdm, torchrun, etc. are found
ENV PATH=/home/appuser/.local/bin:$PATH

# Set the working directory
WORKDIR /workspace

# Clone the ComfyUI repository (replace URL with the official repo)
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git

# Change directory to the ComfyUI folder
WORKDIR /workspace/ComfyUI

# Install ComfyUI dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY install-plugin.sh /workspace
RUN chmod +x /workspace/install-plugin.sh

RUN mkdir -p /workspace/ComfyUI/custom_nodes \
 && /workspace/install-plugin.sh https://github.com/ltdrdata/ComfyUI-Manager.git ComfyUI-Manager \
 && /workspace/install-plugin.sh https://github.com/cubiq/ComfyUI_essentials.git ComfyUI_essentials \
 && /workspace/install-plugin.sh https://github.com/crystian/ComfyUI-Crystools.git ComfyUI-Crystools \
 && /workspace/install-plugin.sh https://github.com/rgthree/rgthree-comfy.git rgthree-comfy \
 && /workspace/install-plugin.sh https://github.com/kijai/ComfyUI-KJNodes.git ComfyUI-KJNodes \
 && /workspace/install-plugin.sh https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git ComfyUI_UltimateSDUpscale \
 && /workspace/install-plugin.sh https://github.com/Acly/comfyui-inpaint-nodes comfyui-inpaint-nodes \
 && /workspace/install-plugin.sh https://github.com/cubiq/ComfyUI_IPAdapter_plus comfyui_ipadapter_plus \
 && /workspace/install-plugin.sh https://github.com/1038lab/ComfyUI-JoyCaption/ ComfyUI-JoyCaption \
 && /workspace/install-plugin.sh https://github.com/un-seen/comfyui_segment_anything_plus comfyui_segment_anything_plus \
 && /workspace/install-plugin.sh https://github.com/pythongosssss/ComfyUI-WD14-Tagger comfyui-wd14-tagger \
 && pip uninstall -y transformers && pip install -U transformers==4.37 sentence-transformers==2.7.0 \
 && pip cache purge

# Expose the port that ComfyUI will use (change if needed)
EXPOSE 8188

# Copy and enable the startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
 && mkdir -p /workspace/ComfyUI/user /workspace/ComfyUI/user/default \
 && chown -R $UID:$GID /workspace

# Switch to non-root user
USER $UID:$GID

# Run entrypoint first, then start ComfyUI
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/venv/main/bin/python", "/workspace/ComfyUI/main.py", "--listen", "0.0.0.0", "--lowvram"]
