classdef ScannerRecon
    
    properties
        
    end
    
    methods
        
        function SR = ScannerRecon( lab_filename, raw_filename, varargin )
            
            
            % ---------- Place you own code here ----------
            
            r = MRecon(lab_filename, raw_filename);%
            r.Perform;
            
            % ---------- Place you own code here ----------
            
                                                
            % Specify the output formats
            r.Parameter.Recon.ExportRECImgTypes = {'M'};
            
            % Check for additional inputs (like acquistion number)
            for i = 1:length( varargin )
                if any( strcmpi( varargin{i}, {'acq_no', 'acqno', 'acq'} )) 
                    acq_no = varargin{i+1};
                    if ischar( acq_no ) 
                        acq_no = str2double(acq_no);                                    
                    end
                    r.Parameter.Scan.AcqNo = acq_no;                    
                end  
                if any( strcmpi( varargin{i}, {'protocol_name', 'protocolname'} )) 
                    protocol_name = varargin{i+1};                    
                    r.Parameter.Scan.ProtocolName = protocol_name;                    
                end
            end
            
            % Write the rec and par files
            try
                r.WriteRec('G:\patch\pride\tempoutputseries\DBIEX.REC');
                r.WriteXMLPar('G:\patch\pride\tempoutputseries\DBIEX.XML');
            catch
                r.WriteRec('DBIEX.REC');
                r.WriteXMLPar('DBIEX.XML');
            end
            
            
        end
        
    end
end


