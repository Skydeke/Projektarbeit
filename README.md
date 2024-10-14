This repository contains the [Latex](https://www.latex-project.org/) files to build my report on the mandatory project required to get my degree.

The entire latex files are built using the VS-Code extension [LaTeX-Workshop](https://github.com/James-Yu/LaTeX-Workshop). It allows for the LaTeX project to be built from inside a docker container. Just set the image to "my_latex:latest", as described in the [docker-compose.yaml](docker-compose.yaml).
In order to successfully build the project you first need to create that docker image using the following commands:

```bash
docker-compose up
```

Because the LaTeX project uses a different font it needs to be compiled using the 'xelatexmk' command. In the LaTeX-Workshop extension you can specify the command used to build the project. 

It is possible to build the .pdf without any extensions. You just need to run the following command twice. (Twice to make the table of contents work.)
Make sure that you run only one container at one time otherwise, the .pdf will come out messed up.
```bash
docker run -i --rm -w "$(pwd)" -v "$(pwd):$(pwd)" -d my_latex:latest latexmk
```

After all this is done a lot of files should be generated and a pdf file is produced.
Tip: The VS-Code option "latex-workshop.synctex.afterBuild.enabled": true allows for the pdf to scroll to where you have your cursor in the .tex file after it is built. This makes editing the .tex file a lot easier. With LaTeX workshop there also comes a pdf-preview.
