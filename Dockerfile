FROM python:3.9-alpine

WORKDIR /src
ADD     . /src
RUN     python setup.py install


WORKDIR    /workspace
ENV        PYTHONUNBUFFERED=true
ENTRYPOINT ["/usr/local/bin/tfe-run-wait"]
