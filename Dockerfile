FROM btorch/odoo-base:13


SHELL ["/bin/bash", "-xo", "pipefail", "-c"]
ARG TERM=xterm
ARG DEBIAN_FRONTEND=noninteractive


WORKDIR /opt/

# PIP dep Install
RUN pip3 install --no-cache-dir \
  xlwt num2words pysigep \
  suds-jurko-requests xmlsec==1.3.3 \
  urllib3==1.22 pyopenssl==17.5.0 \
  pytrustnfe3 signxml \
  iugu-trustcode click-odoo-contrib \
  ebaysdk==2.1.5 bokeh==1.1.0 \
  mpld3==0.3 pyzbar pdf2image \
  py3o.template py3o.formats \
  genshi>=0.7 raven



# Install some Deps
RUN apt-get update && \
  apt-get install -y dirmngr \
  fonts-noto-cjk gnupg xz-utils \
  python3-phonenumbers python3-pyldap \
  python3-qrcode python3-renderpm \
  python3-slugify python3-vobject \
  python3-watchdog python3-xlrd \
  fonts-liberation libgts-bin libpaper-utils \
  python3-pygments \
  python3-html5lib python3-pyinotify \
  python3-matplotlib vim
 

# Install Odoo
RUN wget --quiet -O - https://nightly.odoo.com/odoo.key | apt-key add - && \
  echo "deb http://nightly.odoo.com/13.0/nightly/deb/ ./" >> /etc/apt/sources.list.d/odoo.list && \
  apt-get update && apt-get install --no-install-recommends -y odoo && \
  pip3 install --no-cache-dir odoo13-addon-mis-builder && \
  rm -rf /var/lib/apt/lists/*


# Copy Files
ADD confs/odoo.conf /etc/odoo/
ADD bin/entrypoint.sh /opt/odoo/
RUN mkdir -p /opt/odoo/extra-addons && \
  mkdir -p /opt/odoo/dados && \
  mkdir -p /opt/odoo/brazil-addons && \
  chown odoo /etc/odoo/odoo.conf && \
  chown odoo /opt/odoo/entrypoint.sh && \
  chown -R odoo /opt/odoo/extra-addons && \
  chown -R odoo /opt/odoo/dados && \
  chown -R odoo /opt/odoo/brazil-addons && \
  chmod +x /opt/odoo/entrypoint.sh


# Expose Odoo services
EXPOSE 8069 8071 8072

WORKDIR /opt/odoo

# Set some enviroment variables
ENV ODOO_RC /etc/odoo/odoo.conf
ENV ODOO_VERSION=13.0
ENV ODOO_PASSWORD=admin
ENV PG_HOST=192.168.1.215
ENV PG_DATABASE=odoov13
ENV PG_PASSWORD=brasil
ENV PG_PORT=5432
ENV PG_USER=odoo
ENV TIME_CPU=600
ENV TIME_REAL=720
ENV LOG_FILE=/var/log/odoo/odoo.log
ENV LONGPOLLING_PORT=8072
ENV WORKERS=3
ENV PORT=8069
ENV SPORT=8071


#CMD ["/sbin/init"]
VOLUME ["/opt/odoo/dados","/opt/odoo/extra-addons","/opt/odoo/brazil-addons"]
ENTRYPOINT ["/opt/odoo/entrypoint.sh"]
CMD ["odoo"]

