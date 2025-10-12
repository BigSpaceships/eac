FROM python:3.13-slim-trixie
MAINTAINER Max Meinhold <mxmeinhold@gmail.com>


RUN apt-get -yq update && \
    apt-get -yq --no-install-recommends install gcc libsasl2-dev libldap2-dev libssl-dev git && \
    apt-get -yq clean all

RUN mkdir /opt/eac

WORKDIR /opt/eac

RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \
    pip install -r requirements.txt

COPY . /opt/eac

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
RUN git config --system --add safe.directory /opt/eac

ARG PORT=8080
ENV PORT=${PORT}
EXPOSE ${PORT}

# --access-logfile - prints access log to stdout
# --error-log - prints errors to stdout
# --capture-output logging and print go to error log (stdout)
CMD ["sh", "-c", "gunicorn app:application --bind=0.0.0.0:${PORT} --access-logfile - --error-log - --capture-output --timeout=600"]
