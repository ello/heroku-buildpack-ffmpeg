FROM heroku/heroku:20-build

ENV BUILD_DIR="${BUILD_DIR:-/app}"
WORKDIR ${BUILD_DIR}

COPY FFmpeg.asc FFmpeg.asc
RUN ["gpg", "--import", "FFmpeg.asc"]
RUN ["rm", "FFmpeg.asc"]

RUN apt-get update && apt-get install -y yasm libmp3lame-dev

RUN ["gem", "install", "bundler", "-N"]
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN ["bundle"]

# Install libs for gif to mp4 conversion - also must be install on dyno, eg via Aptfile
RUN apt-get update && apt-get install -y x264 libx264-155 libx264-dev

ENV FFMPEG_DIR="${BUILD_DIR}/.ffmpeg"
VOLUME ["${FFMPEG_DIR}.build"]

COPY Rakefile Rakefile
COPY rakelib rakelib
CMD ["bundle", "exec", "rake"]
