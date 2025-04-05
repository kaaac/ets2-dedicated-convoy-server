FROM cm2network/steamcmd:steam

ARG APP_ID=1948160
ARG SAVEGAME_LOCATION="/home/steam/.local/share/Euro Truck Simulator 2/"
ARG EXECUTABLE="/app/bin/linux_x64/eurotrucks2_server"
ARG DEFAULT_PACKAGES="default_packages/ets2"


ENV SAVEGAME_LOCATION="${SAVEGAME_LOCATION}"
ENV ETS_SERVER_CONFIG_FILE_PATH="${SAVEGAME_LOCATION}server_config.sii"
ENV EXECUTABLE=${EXECUTABLE}
ENV APP_ID=${APP_ID}

WORKDIR /app

USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y python3 libatomic1 libx11-6 python3-venv \
    && apt-get clean

RUN mkdir /api
# Copy the setup script for the virtual environment
COPY setup_venv.sh /api/setup_venv.sh
RUN chmod +x /api/setup_venv.sh

# Copy the script to run the status API
COPY run_status_api.sh /api/run_status_api.sh
RUN chmod +x /api/run_status_api.sh

# Create required dirs
RUN mkdir -p "${SAVEGAME_LOCATION}" \
    && chown steam:steam -R "${SAVEGAME_LOCATION}" \
    && mkdir -p /default_packages

# Create the /opt/venv directory and set permissions for the steam user
RUN mkdir -p /opt/venv \
    && chown steam:steam /opt/venv

COPY ets_server_entrypoint.py /ets_server_entrypoint.py
COPY status_api.py /api/status_api.py
RUN chown -R steam:steam /api
COPY entrypoint.sh /entrypoint
COPY VERSION /version
RUN chmod +x /entrypoint

COPY ["${DEFAULT_PACKAGES}/server_packages.dat", "/default_packages/"]
COPY ["${DEFAULT_PACKAGES}/server_packages.sii", "/default_packages/"]

USER steam

ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT [ "/entrypoint" ]
CMD [ "bash", "-c", "${EXECUTABLE}" ]