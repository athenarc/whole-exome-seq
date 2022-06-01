#!/usr/bin/env cwl-runner

class: Workflow

cwlVersion: v1.0

requirements:
    - class: ScatterFeatureRequirement

inputs:
    raw_files_directory:
        type: Directory
    
    # bwa mem inputs:
    bwa_mem_sec_shorter_split_hits:
        type: boolean
        default: true
    bwa_mem_num_threads:
        type: int
        default: 16
    bwa_mem_ref_genome:
        type: File
        secondaryFiles:
            - .amb
            - .ann
            - .bwt
            - .pac
            - .sa
    
    # SAMtools inputs:
    samtools_view_isbam:
        type: boolean
        default: false
    samtools_view_readswithoutbits:
        type: int?
    samtools_view_collapsecigar:
        type: boolean
        default: false
    samtools_view_bS:
        type: boolean
        default: true
    samtools_view_readsingroup:
        type: string?
    samtools_view_uncompressed:
        type: boolean
        default: false
    samtools_view_readtagtostrip:
        type: string[]?
    samtools_view_input:
        type: File?
    samtools_view_readsquality:
        type: int?
    samtools_view_readswithbits:
        type: int?
    samtools_view_cigar:
        type: int?
    samtools_view_iscram:
        type: boolean
        default: false
    samtools_view_threads:
        type: int?
    samtools_view_fastcompression:
        type: boolean
        default: false
    samtools_view_samheader:
        type: boolean
        default: false
    samtools_view_count:
        type: boolean
        default: false
    samtools_view_randomseed:
        type: float?
    samtools_view_region:
        type: string?
    samtools_view_readsinlibrary:
        type: string?
    samtools_view_output_name:
        type: string?   
    samtools_fixmate_threads:
        type: int
        default: 16
    samtools_fixmate_output_format:
        type: string
        default: bam
    samtools_sort_compression_level:
        type: int?
    samtools_sort_threads:
        type: int?
        default: 16
    samtools_sort_memory:
        type: string?
    
    # picard AddOrReplaceReadGroups inputs (picard-buildBam.cwl wrapper):
    picard_addorreplacereadgroups_rglb:
        type: string?
    picard_addorreplacereadgroups_rgpl:
        type: string?
    samtools_flagstat_threads:
        type: int?
        default: 16
    
    # GATK HaplotypeCaller inputs (gatk-HaplotypeCaller.cwl wrapper):
    HaplotypeCaller_reference:
        type: File
        secondaryFiles:
            - .amb
            - .ann
            - .bwt
            - .pac
            - .sa
            - .fai
            - ^.dict
    # HaplotypeCaller_INPUT:
    #     type:
    #         type: array?
    #         items: [File, null]
    #     secondaryFiles:
    #         - .bai
    HaplotypeCaller_OUTPUT:
        type: string
    
    # GATK VariantFiltration inputs (gatk-VariantFiltration.cwl wrapper):
    VariantFiltration_reference:
        type: File
        secondaryFiles:
            - .amb
            - .ann
            - .bwt
            - .pac
            - .sa
            - .fai
            - ^.dict
    VariantFiltration_variant:
        type: File?
        secondaryFiles:
            - .tbi
    VariantFiltration_window:
        type: int
        default: 0
    VariantFiltration_cluster:
        type: int
        default: 3
    VariantFiltration_filter_name:
        type:
            type: array
            items: string
    VariantFiltration_filter:
        type:
            type: array
            items: string
    VariantFiltration_OUTPUT:
        type: string
    
    # GATK SelectVariants inputs (gatk-SelectVariants.cwl wrapper):
    SelectVariants_reference:
        type: File
        secondaryFiles:
            - .amb
            - .ann
            - .bwt
            - .pac
            - .sa
            - .fai
            - ^.dict
    SelectVariants_variant:
        type: File?
    SelectVariants_exclude_filter:
        type: boolean
        default: true
    SelectVariants_OUTPUT:
        type: string
    
    # ANNOVAR table_annovar.pl inputs (table-annovar.cwl wrapper):
    table_annovar_query_file:
        type: File?
    table_annovar_database_location:
        type: Directory
    table_annovar_build_over:
        type: string
        default: hg19
    table_annovar_output_name:
        type: string
    table_annovar_remove:
        type: boolean
        default: true
    table_annovar_protocol:
        type: string
    table_annovar_operation:
        type: string
    table_annovar_na_string:
        type: string
        default: .
    table_annovar_vcfinput:
        type: boolean
        default: true
    table_annovar_otherinfo:
        type: boolean
        default: true
    table_annovar_convert_arg:
        type: string?

steps:
    get_raw_files:
        run: ../wrappers/get-raw-files.cwl
        in:
            DIRECTORY: raw_files_directory
        out: [raw_files]
    split_single_paired:
        run: ../wrappers/split-single-paired.cwl
        in:
            input_files: get_raw_files/raw_files
        out: [single_files, 
              paired_files,
              trim_galore_for_single,
              trim_galore_for_paired,
              fastqc_for_single,
              fastqc_for_paired]
    bwa_mem_single:
        run: ../wrappers/bwa-mem.cwl
        scatterMethod: dotproduct
        scatter:
        - trimmed_fq_read1
        in:
            sec_shorter_split_hits: bwa_mem_sec_shorter_split_hits
            num_threads: bwa_mem_num_threads
            ref_genome: bwa_mem_ref_genome
            trimmed_fq_read1: split_single_paired/single_files
        out: [output]
    split_paired_read1_read2:
        run: ../wrappers/split-paired-read1-read2.cwl
        in:
            paired_files: split_single_paired/paired_files
        out: [reads_1, reads_2]
    bwa_mem_paired:
        run: ../wrappers/bwa-mem.cwl
        scatterMethod: dotproduct
        scatter:
        - trimmed_fq_read1
        - trimmed_fq_read2
        in:
            sec_shorter_split_hits: bwa_mem_sec_shorter_split_hits
            num_threads: bwa_mem_num_threads
            ref_genome: bwa_mem_ref_genome
            trimmed_fq_read1: split_paired_read1_read2/reads_1
            trimmed_fq_read2: split_paired_read1_read2/reads_2
        out: [output]
    merge_bwa_sam_files:
        run: ../wrappers/merge-bwa-sam-files.cwl
        in: 
            single_files: bwa_mem_single/output
            paired_files: bwa_mem_paired/output
        out: [total_sam_files,
              names_basenames,
              names_bam_raw,
              names_bam_fixed,
              names_bam_sorted,
              names_bam_uniq,
              names_bam_uniq_rg,
              names_txt_align_stats,
              names_txt_coverage_mean,
              names_txt_count_ontarget,
              names_txt_count_total,
              names_rgids,
              names_rgpus]
    samtools_view_conversion:
        run: ../wrappers/samtools-view.cwl
        scatterMethod: dotproduct
        scatter:
        - input
        - output_name
        in:
            isbam: samtools_view_isbam
            readswithoutbits: samtools_view_readswithoutbits
            collapsecigar: samtools_view_collapsecigar
            bS: samtools_view_bS
            readsingroup: samtools_view_readsingroup
            uncompressed: samtools_view_uncompressed
            readtagtostrip: samtools_view_readtagtostrip
            input: merge_bwa_sam_files/total_sam_files
            readsquality: samtools_view_readsquality
            readswithbits: samtools_view_readswithbits
            cigar: samtools_view_cigar
            iscram: samtools_view_iscram
            threads: samtools_view_threads
            fastcompression: samtools_view_fastcompression
            samheader: samtools_view_samheader
            count: samtools_view_count
            randomseed: samtools_view_randomseed
            region: samtools_view_region
            readsinlibrary: samtools_view_readsinlibrary
            output_name: merge_bwa_sam_files/names_bam_raw
        out: [output]
    samtools_fixmate:
        run: ../wrappers/samtools-fixmate.cwl
        scatterMethod: dotproduct
        scatter:
        - input_file
        - output_file_name
        in:
            threads: samtools_fixmate_threads
            output_format: samtools_fixmate_output_format
            input_file: samtools_view_conversion/output
            output_file_name: merge_bwa_sam_files/names_bam_fixed
        out: [output]
    samtools_sort:
        run: ../wrappers/samtools-sort.cwl
        scatterMethod: dotproduct
        scatter:
        - input
        - output_name
        in:
            compression_level: samtools_sort_compression_level 
            threads: samtools_sort_threads 
            memory: samtools_sort_memory 
            input: samtools_fixmate/output
            output_name: merge_bwa_sam_files/names_bam_sorted
        out: [sorted]
    samtools_view_remove:
        run: ../wrappers/samtools-view.cwl
        scatterMethod: dotproduct
        scatter:
        - input
        - output_name
        in:
            isbam: 
                default: true 
            readswithoutbits: 
                default: 0x904 
            collapsecigar: samtools_view_collapsecigar
            bS: 
                default: false
            readsingroup: samtools_view_readsingroup
            uncompressed: samtools_view_uncompressed
            readtagtostrip: samtools_view_readtagtostrip
            input: samtools_sort/sorted
            readsquality: samtools_view_readsquality
            readswithbits: samtools_view_readswithbits
            cigar: samtools_view_cigar
            iscram: samtools_view_iscram
            threads: samtools_view_threads
            fastcompression: samtools_view_fastcompression
            samheader: 
                default: true 
            count: samtools_view_count
            randomseed: samtools_view_randomseed
            region: samtools_view_region
            readsinlibrary: samtools_view_readsinlibrary
            output_name: merge_bwa_sam_files/names_bam_uniq
        out: [output]
    picard_addorreplacereadgroups:
        run: ../wrappers/picard-buildBam.cwl
        scatterMethod: dotproduct
        scatter:
        - INPUT
        - OUTPUT
        - rgid
        - rgpu
        - rgsm
        in: 
            INPUT: samtools_view_remove/output
            OUTPUT: merge_bwa_sam_files/names_bam_uniq_rg
            rgid: merge_bwa_sam_files/names_rgids
            rglb: picard_addorreplacereadgroups_rglb 
            rgpl: picard_addorreplacereadgroups_rgpl 
            rgpu: merge_bwa_sam_files/names_rgpus
            rgsm: merge_bwa_sam_files/names_basenames
        out: [output]
    samtools_index:
        run: ../wrappers/samtools-index.cwl
        scatterMethod: dotproduct
        scatter:
        - alignments
        in:
            alignments: picard_addorreplacereadgroups/output
        out: [alignments_with_index]
    samtools_flagstat:
        run: ../wrappers/samtools-flagstat.cwl
        scatterMethod: dotproduct
        scatter:
        - input
        - output_name
        in:
            threads: samtools_flagstat_threads
            input: picard_addorreplacereadgroups/output
            output_name: merge_bwa_sam_files/names_txt_align_stats
        out: [output]
    samtools_view_count_total:
        run: ../wrappers/samtools-view.cwl
        scatterMethod: dotproduct
        scatter:
        - input
        - output_name
        in:
            isbam: samtools_view_isbam
            readswithoutbits: samtools_view_readswithoutbits
            collapsecigar: samtools_view_collapsecigar
            bS: 
                default: false
            readsingroup: samtools_view_readsingroup
            uncompressed: samtools_view_uncompressed
            readtagtostrip: samtools_view_readtagtostrip
            input: picard_addorreplacereadgroups/output
            readsquality: samtools_view_readsquality
            readswithbits: samtools_view_readswithbits
            cigar: samtools_view_cigar
            iscram: samtools_view_iscram
            threads: samtools_view_threads
            fastcompression: samtools_view_fastcompression
            samheader: samtools_view_samheader
            count: 
                default: true # samtools_view_count
            randomseed: samtools_view_randomseed
            region: samtools_view_region
            readsinlibrary: samtools_view_readsinlibrary
            output_name: merge_bwa_sam_files/names_txt_count_total
        out: [output]
    gatk_HaplotypeCaller:
        run: ../wrappers/gatk-HaplotypeCaller.cwl
        in:
            reference: HaplotypeCaller_reference
            INPUT: samtools_index/alignments_with_index
            OUTPUT: HaplotypeCaller_OUTPUT
        out: [output]
    gatk_VariantFiltration:
        run: ../wrappers/gatk-VariantFiltration.cwl
        in:
            reference: VariantFiltration_reference
            variant: gatk_HaplotypeCaller/output
            window: VariantFiltration_window
            cluster: VariantFiltration_cluster
            filter_name: VariantFiltration_filter_name
            filter: VariantFiltration_filter
            OUTPUT: VariantFiltration_OUTPUT
        out: [output]
    gatk_SelectVariants:
        run: ../wrappers/gatk-SelectVariants.cwl
        in:
            reference: SelectVariants_reference
            variant: gatk_VariantFiltration/output
            exclude_filter: SelectVariants_exclude_filter
            OUTPUT: SelectVariants_OUTPUT
        out: [output]
    table_annovar:
        run: ../wrappers/table-annovar.cwl
        in:
            query_file: gatk_SelectVariants/output
            database_location: table_annovar_database_location
            build_over: table_annovar_build_over
            output_name: table_annovar_output_name
            remove: table_annovar_remove
            protocol: table_annovar_protocol
            operation: table_annovar_operation
            na_string: table_annovar_na_string
            vcfinput: table_annovar_vcfinput
            otherinfo: table_annovar_otherinfo
            convert_arg: table_annovar_convert_arg
        out: [multianno_vcf, multianno_txt, avinput]

outputs: #[]
    o_merge_bwa_sam_files:
        type: File[]
        outputSource: merge_bwa_sam_files/total_sam_files
    o_samtools_view_conversion:
        type: File[]
        outputSource: samtools_view_conversion/output
    o_samtools_fixmate:
        type: File[]
        outputSource: samtools_fixmate/output
    o_samtools_sort:
        type: File[]
        outputSource: samtools_sort/sorted
    o_samtools_view_remove:
        type: File[]
        outputSource: samtools_view_remove/output
    o_picard_addorreplacereadgroups:
        type: File[]
        outputSource: picard_addorreplacereadgroups/output
    o_samtools_index:
        type: File[]
        outputSource: samtools_index/alignments_with_index
    o_samtools_flagstat:
        type: File[]
        outputSource: samtools_flagstat/output
    o_samtools_view_count_total:
        type: File[]
        outputSource: samtools_view_count_total/output
    o_gatk_HaplotypeCaller:
        type: File
        outputSource: gatk_HaplotypeCaller/output
    o_gatk_VariantFiltration: 
        type: File
        outputSource: gatk_VariantFiltration/output
    o_gatk_SelectVariants:
        type: File
        outputSource: gatk_SelectVariants/output
    o_table_annovar_multianno_vcf:
        type: File
        outputSource: table_annovar/multianno_vcf
    o_table_annovar_multianno_txt:
        type: File
        outputSource: table_annovar/multianno_txt
    o_table_annovar_avinput:
        type: File
        outputSource: table_annovar/avinput

    