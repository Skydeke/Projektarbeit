FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install texlive-full biber texlive-bibtex-extra texlive-fonts-recommended texlive-fonts-extra -y
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
RUN apt install ttf-mscorefonts-installer -y && fc-cache -f
RUN apt install make build-essential debhelper -y

COPY dependantcies/latex-rwustyle /latex-rwustyle
RUN cd /latex-rwustyle && make install-home
COPY dependantcies/fonts-barlow /fonts-barlow
RUN cd /fonts-barlow && dpkg-buildpackage -uc -us && dpkg -i ../fonts-barlow_1.422_all.deb