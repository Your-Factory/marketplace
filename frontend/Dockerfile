FROM continuumio/miniconda3
COPY environment.yml /app/environment.yml
RUN conda env create -f /app/environment.yml
ENV PATH /opt/conda/envs/marketplace/bin:$PATH
COPY ./ /app/
WORKDIR /app
CMD ["flask", "run", "-h", "0.0.0.0"]
