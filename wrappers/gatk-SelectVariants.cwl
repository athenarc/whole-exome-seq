cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/gatk4:4.2.3.0--hdfd78af_1 

baseCommand: [gatk, SelectVariants]

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
  variant:
    type: File
    inputBinding:
      prefix: -V
      position: 2
      shellQuote: false
  exclude_filter:
    type: boolean
    default: true
    inputBinding:
      prefix: --exclude-filtered
      position: 3
      shellQuote: false
  OUTPUT:
    type: string
    inputBinding:
      prefix: --output
      position: 4
      shellQuote: false
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.OUTPUT)