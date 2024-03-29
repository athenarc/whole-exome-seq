cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/gatk4:4.2.3.0--hdfd78af_1 

baseCommand: [gatk, VariantFiltration]

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
    secondaryFiles:
      - .tbi
    inputBinding:
      prefix: -V
      position: 2
      shellQuote: false
  window:
    type: int
    default: 0
    inputBinding:
      prefix: -window
      position: 3
      shellQuote: false
  cluster:
    type: int
    default: 3
    inputBinding:
      prefix: -cluster
      position: 4
      shellQuote: false
  filter_name:
    type:
      type: array
      items: string
      inputBinding:
        prefix: --filter-name
    inputBinding:
      position: 5
      shellQuote: false
  filter:
    type:
      type: array
      items: string
      inputBinding:
        prefix: -filter
    inputBinding:
      position: 6
  OUTPUT:
    type: string
    inputBinding:
      prefix: --output
      position: 7
      shellQuote: false
outputs:
  output:
    type: File
    secondaryFiles: .idx
    outputBinding:
      glob: $(inputs.OUTPUT)