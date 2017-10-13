function success = helpwin(topic,pagetitle,helptitle,varargin)
%HELPWIN Online help displayed in the Help window
%   HELPWIN TOPIC displays the help text for the specified TOPIC inside the
%   Help window.  Links are created to functions referenced in the 'See Also'
%   line of the help text.
%
%   HELPWIN(HELP_STR,TITLE) displays the string HELP_STR in the help
%   window.  HELP_STR may be passed in as a string with each line separated
%   by carriage returns, a column vector cell array of strings with each cell
%   (row) representing a line or as a string matrix with each row representing
%   a line.  The optional string TITLE will appear in the title banner.
%
%   HELPWIN({TITLE1 HELP_STR1;TITLE2 HELP_STR2;...},PAGE) displays one page
%   of multi-page help text.  Note: this calling sequence is deprecated and
%   is provided only for compatibility with previous versions of HELPWIN.
%   The multi-page help text is passed in as a
%   cell array of strings or cells containing TITLE and HELP_STR pairs.
%   Each row of the multi-page help text cell array (dimensioned number of
%   pages by 2) consists of a title string paired with a string, cell array
%   or string matrix of help text.  The second argument PAGE is a string
%   which must match one of the TITLE entries in the multi-page help text.
%   The matching TITLE represents the page that is to be displayed first.
%   If no second argument is given, the first page is displayed.
%
%   HELPWIN displays the default topic list in the Help browser.
%
%   HELPWIN will be removed in a future release. Use DOC instead. 
%
%   See also HELP, DOC, LOOKFOR, WHAT, WHICH, DIR, MORE.

%   Copyright 1984-2011 The MathWorks, Inc.
%   $Revision: 1.1.8.25.2.1 $ $Date: 2012/01/05 22:06:18 $

if nargout
    success = true;
end

% --------------------- mb: MRecon --------------------------------
switch topic
    case 'MReconDoc.Parameter'
        topic = 'MRparameterDoc';
    case 'MReconDoc.Data'
        topic = 'MRdataDoc';
    case 'MRparameterDoc.Recon'
        topic = 'ReconParsDoc';
    case 'MRparameterDoc.Scan'
        topic = 'ScanParsDoc';
    case 'MRparameterDoc.Encoding'
        topic = 'EncodingParsDoc';    
    case 'MRparameterDoc.ReconFlags'
        topic = 'ReconFlagParsDoc';        
    case 'MRparameterDoc.Cardiac'
        topic = 'CardiacParsDoc';    
    case 'MRparameterDoc.Chunk'
        topic = 'ChunkParsDoc';      
    case 'MRparameterDoc.Gridder'
        topic = 'GridderParsDoc';   
    case 'MRparameterDoc.Parameter2Read'
        topic = 'Parameter2ReadParsDoc';       
    case 'MRparameterDoc.Spectro'
        topic = 'SpectroParsDoc';
    case 'SpectroParsDoc.Averaging'
        topic = 'AveragingParsDoc';
    otherwise
end

% Make sure that we can support the helpwin command on this platform.
errormsg = javachk('mwt', mfilename);
if ~isempty(errormsg)
    error('MATLAB:doc:UnsupportedPlatform', errormsg.message);
end

% This function has to support the old helpwin syntax, which
% provides for three disparate cases.
% Case 1: HELPWIN TOPIC, to display function or topic help (same as HELP function).
% Case 2: HELPWIN(HELP_STR,TITLE), to display an arbitrary help string.
% Case 3: HELPWIN({TITLE1 HELP_STR1;TITLE2 HELP_STR2;...},PAGE)
% to display multi-page help.

% Is this multi-page help text?  (case 3 above)
if nargin>0 && iscell(topic) && (size(topic,2) > 1)
    if nargin < 2
        pagetitle = '';
        helptitle = '';
    elseif nargin < 3
        helptitle = pagetitle;
    end
    if nargin > 3
        displayOption = varargin{1};
    else
        displayOption = '';
    end
    handle_multipage_help(topic,pagetitle,helptitle,displayOption)
    return;
end

if (nargin == 0)
    html = help2html;
elseif (nargin == 1)
    html = help2html(topic);
elseif (nargin > 1)
    if nargin > 3
        helpCommandOption = varargin{1};
    else
        helpCommandOption = '-helpwin';
    end
    html = help2html(topic,pagetitle,helpCommandOption);
end

if isempty(html) && nargout
    success = false;
else
    web(['text://' html], '-helpbrowser');
end

function handle_multipage_help(topic,pagetitle,helptitle,displayOption)
if iscell(topic) && numel(topic) == 2
    % This isn't really multipage help.  Use a different helpwin syntax.
    helpwin(topic{2},topic{1});
    return;
end

% Alternate between multiple temp files (starting with matlabTemp1.html).
% Multiple files are needed because a single file won't refresh properly,
% and to allow for a certain level of "Back" operations in the browser.
% You have to pass the browser a new file name each time to get it to reload.
dirName = char(com.mathworks.services.Prefs.getPropertyDirectory);
currFile = char(com.mathworks.mlservices.MLHelpServices.getCurrentLocation);
tempNum = regexp(currFile,'matlabTemp(\d).html','tokens','once');
if ~isempty(tempNum)
    tempNum = rem(str2double(tempNum),5) + 1;
else
    tempNum = 1;
end
fileName = fullfile(dirName,['matlabTemp' num2str(tempNum) '.html']);

% Workaround for ICE bug involving named anchors
fnPos = findstr(fileName, 'matlabTemp');
shortName = fileName(fnPos:length(fileName));

% Starting building HTML output, beginning with optional title banner.
% At top put header with links to each page.
% Only show header if more than one page.
dom = com.mathworks.xml.XMLUtils.createDocument('help-info');
dom.getDomConfig.setParameter('cdata-sections',true);
addTextNode(dom,dom.getDocumentElement,'title',helptitle);
addTextNode(dom,dom.getDocumentElement,'filename',shortName);

helpdir = fileparts(mfilename('fullpath'));
helpdir = ['file:///' strrep(helpdir,'\','/')];
addTextNode(dom,dom.getDocumentElement,'helptools-dir',helpdir);

if ~strcmp(helptitle,pagetitle)
    addTextNode(dom,dom.getDocumentElement,'pagetitle',pagetitle);
end
numpages = size(topic,1);
for x = 1:numpages
    pgtitle = char(topic(x,1));
    helpNode = help2xml(dom,pgtitle,pgtitle,'-helpwin');
    addAttribute(dom,helpNode,'id',num2str(x));
end

addTextNode(dom,dom.getDocumentElement,'default-topics-text',getString(message('MATLAB:helpwin:sprintf_DefaultTopics')));
xslfile = fullfile(fileparts(mfilename('fullpath')),'private','helpwin.xsl');
html = xslt(dom,xslfile,'-tostring');

for x = 1:numpages
    helpstr = char(topic(x,2));
    if (size(helpstr,1) > 1)
        % Convert a 2-D char array to 1-D.
        c = cellstr(helpstr);
        helpstr = sprintf('%s\n',c{:});
    end
       
    html = regexprep(html,['\s*<!--\s*helptext ' num2str(x) '\s*-->'], sprintf('\n\n%s',regexptranslate('escape',helpstr)));
end

if strcmp(displayOption,'-nofile')
    web(['text://' html],'-helpbrowser');
else
    fid = fopen(fileName,'w');
    fprintf(fid,'%s', html);
    fclose(fid);

    % Get the index for the requested page from the cell array.
    % Display the appropriate page.
    ind = strmatch(pagetitle,topic(:,1),'exact');
    if isempty(ind), ind = 1; end
    if ind == 1
        web(fileName, '-helpbrowser');
    else
        namedAnchor = sprintf('#topic%u',ind);
        web([fileName namedAnchor ], '-helpbrowser');
    end
end

function addTextNode(dom,parent,name,text)
child = dom.createElement(name);
child.appendChild(dom.createTextNode(text));
parent.appendChild(child);

function addAttribute(dom,elt,name,text)
att = dom.createAttribute(name);
att.appendChild(dom.createTextNode(text));
elt.getAttributes.setNamedItem(att);



