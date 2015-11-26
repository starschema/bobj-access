FROM virtdb/virtdb-builder

USER root
RUN mkdir -p repo
ADD . repo
RUN chown -R virtdb-demo:virtdb-demo repo
USER virtdb-demo
WORKDIR repo
