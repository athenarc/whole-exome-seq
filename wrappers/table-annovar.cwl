cwlVersion: v1.0
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: bioinfochrustrasbourg/annovar:2018Apr16

baseCommand: table_annovar.pl

inputs:
  query_file:
    type: File
    inputBinding:
      position: 2
  database_location:
    type: Directory
    inputBinding:
      position: 3
  build_over:
    type: string
    default: hg19
    inputBinding:
      prefix: -buildver
      position: 4
  output_name:
    type: string
    inputBinding:
      position: 5
      prefix: -out
  remove:
    type: boolean
    default: true
    inputBinding:
      position: 6
      prefix: -remove
  protocol:
    type: string
    inputBinding:
      prefix: -protocol
      position: 7
  operation:
    type: string
    inputBinding:
      prefix: -operation
      position: 8
  na_string:
    type: string
    default: .
    inputBinding:
      prefix: -nastring
      position: 9
  vcfinput:
    type: boolean
    default: true
    inputBinding:
      position: 10
      prefix: -vcfinput
  otherinfo:
    type: boolean
    default: true
    inputBinding:
      position: 11
      prefix: -otherinfo
  convert_arg:
    type: string?
    inputBinding:
      position: 12
      prefix: --convertarg
outputs:
  multianno_vcf:
    type: File
    outputBinding:
      glob: "*.vcf"
  multianno_txt:
    type: File
    outputBinding:
      glob: "*.txt"
  avinput:
    type: File
    outputBinding:
      glob: "*.avinput"