FROM golang:latest
RUN go install github.com/0xPolygon/polygon-edge@develop

WORKDIR /
#Create files with node id and public key for later usage

RUN mkdir genesis
RUN chown -R polygon-edge ./genesis
COPY ./launch.sh .
RUN chmod +rx ./launch.sh

CMD ["sh", "-c", "./launch.sh"]