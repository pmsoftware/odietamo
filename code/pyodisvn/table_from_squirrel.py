x = '''ID - Story
11227 - CMS Refactor Cognos Model
11117 - MDM: Load OBIT Death List to MOI
12580 - MDM: One-Off Load Of SWIFT Historic Data , Members
12579 - MDM: One-Off Load Of SWIFT Historic Data , Intermediaries
12581 - MDM: One-Off Load Of SWIFT Historic Data , Providers
13781 - MDM: Swift ETL Change: PEOPLE
18051 - MDM: UAT Incremental Refresh
8684 - CMS Intermediary and Int Employee Details (from SWIFT)
17920 - CMS Intermediary Sales Linkage (from SWIFT)
20291 - MDM: REMIX remapping for R1
14043 - CMS , Loading a partnership list into MOI (person prospects data from affiliates)
14048 - MDM: TECHNICAL: Extract Partnership Data
11546 - MDM: Automate Person Extraction SWIFT
11547 - MDM: Automate Person Extraction REMIX
11548 - MDM: Automate Person Extraction MAGENTA
18472 - Delete CACI 10k Sample data
21137 - MDM: FINAL: Swift Members Extract
21139 - MDM: FINAL: Swift People Extract
21140 - MDM: FINAL: Point Extract
21141 - MDM: FINAL: Magenta Extract
21142 - MDM: FINAL: IBS Extract
21143 - MDM: FINAL: Remix Extract
21144 - MDM: FINAL: 3rd party CACI Extract
21145 - MDM: FINAL: 3rd party OBIT Extract
21146 - MDM: FINAL: 3rd party Partnership Extract
23185 - Partnership feed into SCV Xref
23186 - MDM: golden record dataset , SWIFT People into SCV Xref
23187 - MDM: golden record dataset , Remix Members into SCV Xref
23188 - MDM: golden record dataset , Remix dependants into SCV Xref
23416 - MDM: REMIX Workaround for MOI Replica CC_XREF Extractions
23595 - CPOnvert all MDM outputs into Append only ETLs
23646 - PARTY_ROLE_CLAIMS needs to point to physicalised tables
16765 - MDM: Swift Secure Groups CHANGE To current ETL'''

def tablefy(txt):
    delim = " - "
    #somehow work out howmany cols to have
    colmaxs = [ 0,0 ]
    outstr = ''
    underline = ''
    lines = txt.split("\n")
    hdr = lines[0]
    
    for line in txt.split("\n"):
        
        cols = line.split(delim)
        print cols
        for i, col in enumerate(cols):
            if len(col) > colmaxs[i]: colmaxs[i] = len(col)

    for collen in colmaxs:
        underline += "="*collen + " "
    underline += "\n"
    outstr += underline
    
    for i, col in enumerate(hdr.split(delim)):
        outstr += col.ljust(colmaxs[i]) + " "
    outstr += "\n"

    outstr += underline

    for line in txt.split("\n"):
        cols = line.split(delim)
        for i, col in enumerate(cols):
            outstr += col.ljust(colmaxs[i]) + " "
        outstr += "\n"
    outstr += underline
    print outstr 
    
        

tablefy(x)