FROM alpine:3.14

ENV PUID=1000
ENV PGID=1000
ENV USER_NAME=user
ENV USER_PASS=NaQuaiRiu7aiphiedee2yungaem3tu7i
ENV PORT=2222

RUN \
 apk add --no-cache \
	bash \
	curl \
	tzdata \
	xz \
	nano \
	coreutils \
	shadow

ARG OPENSSH_RELEASE=8.6_p1-r3
LABEL openssh_version="OpenSSH Version: ${OPENSSH_RELEASE}"
RUN \
 apk add --no-cache \
	openssh==${OPENSSH_RELEASE}
    
EXPOSE 22/tcp
    
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["start"]
