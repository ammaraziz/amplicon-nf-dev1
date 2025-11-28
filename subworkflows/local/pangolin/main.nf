include { PANGOLIN_RUN } from '../../../modules/nf-core/pangolin/run'
include { PANGOLIN_UPDATEDATA } from '../../../modules/nf-core/pangolin/updatedata'

workflow CALL_LINEAGES {
    take: 
        ch_consensus // channel from amplicon-nf.nf 
    
    main:
    
        // ch_all_consensus_fasta = ch_consensus
        //     .map { _meta, fasta -> fasta }
        //     .collectFile(name: 'all_consensus.fasta')
        //     .map { multi_fasta ->[[id: 'all_consensus.fasta'], multi_fasta]}

        ch_all_consensus_fasta = ch_consensus
            .collectFile(name: 'all_consensus.fasta', elements: { meta, fasta -> fasta })
            .map { multi_fasta -> [[id: 'all_consensus.fasta'], multi_fasta] }

        SEQKIT_REPLACE_NC(ch_all_consensus_fasta)

        PANGOLIN_UPDATEDATA('pangolin_db')
        PANGOLIN_RUN (
            SEQKIT_REPLACE_NC.out.fastx,
            PANGOLIN_UPDATEDATA.out.db
        )
    
    emit:
        versions= PANGOLIN_RUN.out.versions.first()
        pangolin_tsv = PANGOLIN_RUN.out.tsv.map {_meta, tsv -> tsv}
}





