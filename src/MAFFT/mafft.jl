# Julia Wrapper for MAFFT (http://mafft.cbrc.jp/alignment/software/)
module MAFFT
export mafft, mafft_from_string, mafft_linsi, mafft_ginsi, print_aligned_fasta

    using FastaIO

    # calls MAFFT and returns aligned FASTA
    # fasta_in: path to FASTA file
    # args: optional commandline arguments for MAFFT (array of strings)
    function mafft(fasta_in::String, args=["--auto"])
        try success(`mafft -v`)
        catch
            error("MAFFT is not installed.")
        end

        fasta = readall(`mafft '--quiet' $args $fasta_in`)
        fr = readall(FastaReader(IOBuffer(fasta)))
        return fr
    end
    
    # calls MAFFT with the given FASTA string as input and returns aligned FASTA
    # fasta_in: FASTA string
    # args: optional commandline arguments for MAFFT (array of strings)
    function mafft_from_string(fasta_in::String, args=["--auto"])
        # write to tempfile because mafft can not read from stdin
        tempfile_path, tempfile_io = mktemp()
        write(tempfile_io, fasta_in)
        close(tempfile_io)
        return mafft(tempfile_path, args)
    end

    # Accuracy-oriented methods

    """ L-INS-i (probably most accurate; recommended for <200 sequences;
           iterative refinement method incorporating local pairwise alignment
           information)
    """
    function mafft_linsi(fasta_in::String)
        return mafft(fasta_in, ["--localpair", "--maxiterate", "1000"])
    end
    const linsi = mafft_linsi

    """ G-INS-i (suitable for sequences of similar lengths; recommended for
           <200 sequences; iterative refinement method incorporating global
           pairwise alignment information)
    """
    function mafft_ginsi(fasta_in::String)
        return mafft(fasta_in, ["--globalpair", "--maxiterate", "1000"])
    end
    const ginsi = mafft_ginsi

    """ E-INS-i (suitable for sequences containing large unalignable regions;
           recommended for <200 sequences)
    """
    function mafft_einsi(fasta_in::String)
        return mafft(fasta_in, ["--ep", "0", "--genafpair", "--maxiterate", "1000"])
    end
    const einsi = mafft_einsi


    # helper methods

    function print_aligned_fasta(fasta)
        for f in fasta
            println(f[2])
        end
    end
end
