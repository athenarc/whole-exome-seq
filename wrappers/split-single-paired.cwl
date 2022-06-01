cwlVersion: v1.0
class: ExpressionTool

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: input_files
  type: File[]
- id: trim_galore_command
  type: string
  default: echo

outputs:
- id: single_files
  type: File[]
- id: paired_files
  type: File[]
- id: trim_galore_for_single
  type: string
- id: trim_galore_for_paired
  type: string
- id: fastqc_for_single
  type: string
- id: fastqc_for_paired
  type: string

expression: |
  ${
    var single = [];
    var paired = [];
    var flag_single;
    var base_ref;
    var base_target;

    var single_trim_command = inputs.trim_galore_command;
    var paired_trim_command = inputs.trim_galore_command;

    var single_fastqc_command = "fastqc";
    var paired_fastqc_command = "fastqc";

    for(var i = 0; i < inputs.input_files.length; i++){

      if(inputs.input_files[i].basename.includes("R1")){
        base_ref = inputs.input_files[i].basename.split("_R")[0];

        flag_single = 1;

        for(var j = 0; j < inputs.input_files.length; j++){
          base_target = inputs.input_files[j].basename.split("_R")[0];

          if(base_ref == base_target && inputs.input_files[j].basename.includes("R2")){
            flag_single = 0;
            paired.push(inputs.input_files[i]);
            paired.push(inputs.input_files[j]);
            break;
          }
        }

        if(flag_single == 1){
          single.push(inputs.input_files[i]);
        }
      }
      
    }

    if(single.length == 0){
      single_trim_command = "echo";
      single_fastqc_command = "echo";
    }

    if(paired.length == 0){
      paired_trim_command = "echo";
      paired_fastqc_command = "echo";
    }

    return {
      "single_files": single, 
      "paired_files": paired,
      "trim_galore_for_single": single_trim_command,
      "trim_galore_for_paired": paired_trim_command,
      "fastqc_for_single": single_fastqc_command,
      "fastqc_for_paired": paired_fastqc_command
    };
  }