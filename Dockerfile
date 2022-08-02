FROM golang:latest
RUN go install github.com/0xPolygon/polygon-edge@develop
# RUN go install github.com/0xPolygon/polygon-edge@develop
# FROM 0xpolygon/polygon-edge:0.4.1

#CREATE NEW GROUP AND USER, WHICH WE LATER SWITCH TO.
RUN addgroup --system appusers
RUN adduser --system --disabled-password --home /usr/polygon-edge --uid 2001 polygon-edge
RUN adduser polygon-edge appusers

USER root
WORKDIR /
#Create files with node id and public key for later usage
RUN mkdir genesis
RUN chown -R polygon-edge ./genesis
COPY ./launch.sh .
RUN chmod +rx ./launch.sh

CMD ["sh", "-c", "./launch.sh"]
# USER polygon-edge