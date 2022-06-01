cwlVersion: v1.0
class: CommandLineTool
doc: "[bwa](https://github.com/lh3/bwa)"

requirements:
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: "quay.io/biocontainers/bwa:0.7.17--h5bf99c6_8"

baseCommand: bwa
arguments: ["mem"]

inputs:
  sec_shorter_split_hits:
    type: boolean
    default: true
    inputBinding:
      prefix: -M
      position: 1
  num_threads:
    type: int
    default: 16
    inputBinding:
      prefix: -t
      position: 2
  ref_genome:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
    inputBinding:
      position: 3
  trimmed_fq_read1:
    type: File
    inputBinding:
      position: 4
  trimmed_fq_read2:
    type: File?
    inputBinding:
      position: 5

stdout: $(inputs.trimmed_fq_read1.basename.split("_R")[0].concat(".sam"))

outputs:
  output:
    type: stdout