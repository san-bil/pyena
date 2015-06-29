function out=is_ic_doc_host(str)


out = ~isempty(strfind(str, '.doc.ic.ac.uk'));