include { PANGOLIN_RUN } from '../../../modules/nf-core/pangolin/run'
include { PANGOLIN_UPDATEDATA } from '../../../modules/nf-core/pangolin/updatedata'
include { SEQKIT_REPLACE as SEQKIT_REPLACE_NC } from "../../../modules/nf-core/seqkit/replace"

workflow CALL_LINEAGES {
    take: 
        ch_consensus // channel from amplicon-nf.nf 
    
    main:
    
    pango_database = Channel.empty()
    if(params.pangolin_update_data) {
        PANGOLIN_UPDATEDATA('pangolin_db')
        pango_database = PANGOLIN_UPDATEDATA.out.db
    } else if (params.pango_database) {
        pango_database = Channel.value(file(params.pango_database, type: 'dir'))
    } else {
        // do nothing - pass empty database flag
        // this runs pangolin with inbuilt dataset
    }

        // ch_all_consensus_fasta = ch_consensus
        //     .map { _meta, fasta -> fasta }
        //     .collectFile(name: 'all_consensus.fasta')
        //     .map { multi_fasta ->[[id: 'all_consensus.fasta'], multi_fasta]}

        ch_all_consensus_fasta = ch_consensus
            .collectFile(name: 'all_consensus.fasta', elements: { meta, fasta -> fasta })
            .map { multi_fasta -> [[id: 'all_consensus.fasta'], multi_fasta] }

        SEQKIT_REPLACE_NC(ch_all_consensus_fasta)

        PANGOLIN_RUN (
            SEQKIT_REPLACE_NC.out.fastx,
            PANGOLIN_UPDATEDATA.out.db
        )
    
    emit:
        versions= PANGOLIN_RUN.out.versions.first()
        pangolin_tsv = PANGOLIN_RUN.out.tsv.map {_meta, tsv -> tsv}
}





