cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/gatk4:4.2.3.0--hdfd78af_1

baseCommand: [gatk, HaplotypeCaller]

inputs:
  reference:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
    inputBinding:
      prefix: -R
      position: 1
      shellQuote: false
  INPUT:
    type:
      type: array
      items: File
      inputBinding:
        prefix: "-I"
        shellQuote: false
    secondaryFiles:
      - .bai
    inputBinding:
      position: 2
  OUTPUT:
    type: string
    inputBinding:
      prefix: "--output"
      position: 3
      shellQuote: false
outputs:
  output:
    type: File
    secondaryFiles: .tbi
    outputBinding:
      glob: $(inputs.OUTPUT)