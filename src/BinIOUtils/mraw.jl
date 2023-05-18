InfoUtils.info(::Val{:mraw}, file::AbstractString; ka...) = mraw_simple_info(fname)

from(::Val{:mraw}, file::AbstractString; outtype=Float32, intype=UInt16, mmap=false) = frommraw(file; outtype, intype, mmap)


###############################
# frommraw mraw_info
###############################

frommraw(filename::AbstractString; outtype=Float32, intype=UInt16, mmap=false) =
    fromraw(filename, mraw_simple_info(filename)...;
            outtype=(toBool(mmap) ? intype : outtype), intype, mmap)

mraw_info(filename::AbstractString) = begin
    f = (length(filename) > 4 && filename[end-4:end] == ".mraw"
        ? filename[begin:end-5]
        : filename) * ".cihx"

    xmlstr = let
        ff = open(f, "r")
        lines = readlines(ff)
        first_last_line = [ i for i in (1:length(lines)) if (occursin("<cih>", lines[i]) || occursin("</cih>", lines[i])) ]
        xml = join(lines[first_last_line[1]:first_last_line[end]],"\n")
        close(ff)
        xml
    end
    # toNT(XMLDict.xml_dict(XMLDict.parse_xml(xmlstr)))
    XMLDict.xml_dict(XMLDict.parse_xml(xmlstr))
end

mraw_simple_info(filename::AbstractString) =
begin
    info = filename | mraw_info
    frame = info["cih"]["frameInfo"]["totalFrame"] | parse[](Int32)
    height, width = info["cih"]["imageDataInfo"]["resolution"] | values .| parse[](Int32)
    (;frame, width, height)
end

