function doc(topic)
    %  DOC Reference page in Help browser.
    %  
    %     DOC opens the Help browser, if it is not already running, and 
    %     otherwise brings the Help browser to the top.
    %   
    %     DOC FUNCTIONNAME displays the reference page for FUNCTIONNAME in
    %     the Help browser. FUNCTIONNAME can be a function or block in an
    %     installed MathWorks product.
    %   
    %     DOC METHODNAME displays the reference page for the method
    %     METHODNAME. You may need to run DOC CLASSNAME and use links on the
    %     CLASSNAME reference page to view the METHODNAME reference page.
    %   
    %     DOC CLASSNAME displays the reference page for the class CLASSNAME.
    %     You may need to qualify CLASSNAME by including its package: DOC
    %     PACKAGENAME.CLASSNAME.
    %   
    %     DOC CLASSNAME.METHODNAME displays the reference page for the method
    %     METHODNAME in the class CLASSNAME. You may need to qualify
    %     CLASSNAME by including its package: DOC PACKAGENAME.CLASSNAME.
    %   
    %     DOC PRODUCTTOOLBOXNAME displays the documentation roadmap page for
    %     PRODUCTTOOLBOXNAME in the Help browser. PRODUCTTOOLBOXNAME is the
    %     folder name for a product in matlabroot/toolbox. To get
    %     PRODUCTTOOLBOXNAME for a product, run WHICH FUNCTIONNAME, where
    %     FUNCTIONNAME is the name of a function in that product; MATLAB
    %     returns the full path to FUNCTIONNAME, and PRODUCTTOOLBOXNAME is
    %     the folder following matlabroot/toolbox/.
    %   
    %     DOC FOLDERNAME/FUNCTIONNAME displays the reference page for the
    %     FUNCTIONNAME that exists in FOLDERNAME. Use this syntax to display the
    %     reference page for an overloaded function.
    %   
    %     DOC USERCREATEDCLASSNAME displays the help comments from the
    %     user-created class definition file, UserCreatedClassName.m, in an
    %     HTML format in the Help browser. UserCreatedClassName.m must have a
    %     help comment following the classdef UserCreatedClassName statement
    %     or following the constructor method for UserCreatedClassName. To
    %     directly view the help for any method, property, or event of
    %     UserCreatedClassName, use dot notation, as in DOC
    %     USERCREATEDCLASSNAME.METHODNAME. 
    %
    %     Examples:
    %        doc abs
    %        doc signal/abs      % ABS function in the Signal Processing Toolbox
    %        doc handle.findobj  % FINDOBJ method in the HANDLE class
    %        doc handle          % HANDLE class
    %        doc containers.Map  % Map class in the containers method
    %        doc sads            % User-created class, sads
    %        doc sads.steer      % steer method in the user-created class, sads

    %   Copyright 1984-2011 The MathWorks, Inc.
    %   $Revision: 1.1.6.30 $  $Date: 2011/10/01 20:46:29 $
    
    % Make sure that we can support the doc command on this platform.        
    
    errormsg = javachk('mwt', 'The doc command');
    if ~isempty(errormsg)
        error('MATLAB:doc:UnsupportedPlatform', errormsg.message);
    end
    
    % --------------------- mb: MRecon --------------------------------
    if nargin ~= 0 && strcmpi( topic, 'MRecon' )
        topic = 'MReconDoc';
    end
    
    % Make sure docroot is valid.
    if ~helpUtils.isDocInstalled
        % If m-file help is available for this topic, call helpwin.
        if nargin > 0
            if showHelpwin(topic)
                return;
            end
        end
        
        % Otherwise show the appropriate error page.
        htmlFile = fullfile(matlabroot,'toolbox','local','helperr.html');

        if exist(htmlFile, 'file') ~= 2
            error(message('MATLAB:doc:HelpErrorPageNotFound', htmlFile));
        end
        displayFile(htmlFile);
        return
    end
    
    % Case no topic specified.
    if nargin == 0
        % Just open the help browser and display the default startup page.
        com.mathworks.mlservices.MLHelpServices.invoke();
        return
    end
    
    try
        [isOperator, docTopic] = helpUtils.isOperator(topic);
        hasLocalFunction = any(topic==filemarker);
        isMethodOrProp = false;
        
        if ~isOperator && ~hasLocalFunction
            [docTopic, isMethodOrProp] = getClassInformation(topic);
        end
    catch
        [docTopic, isMethodOrProp] = getClassInformation(topic);
        hasLocalFunction = 0;
    end
    
    if isempty(docTopic)
        docTopic = topic;
    end
    
    if ~showTopic(docTopic, isMethodOrProp)
        if hasLocalFunction || ~showWhichTopic(topic,docTopic)
            if ~showHelpwin(topic)
                showNoReferencePageFound(topic);
            end
        end
    end
end

%------------------------------------------
% Helper functions
function success = showWhichTopic(topic,docTopic)
try
    success = false;
    whichTopic = helpUtils.safeWhich(topic);
    % Don't call getClassInformation with the same argument as before.
    if ~isempty(whichTopic) && ~isequal(whichTopic,topic)
        [whichDocTopic, isMethodOrProp] = getClassInformation(whichTopic);
        % Don't call showTopic with the same argument as before.
        if ~isempty(whichDocTopic) && ~isequal(whichDocTopic,docTopic)
            success = showTopic(whichDocTopic, isMethodOrProp);
        end
    end
catch
    success = false;
    whichTopic = matlab.internal.language.introspective.safeWhich(topic);
    % Don't call getClassInformation with the same argument as before.
    if ~isempty(whichTopic) && ~isequal(whichTopic,topic)
        [whichDocTopic, isMethodOrProp] = getClassInformation(whichTopic);
        % Don't call showTopic with the same argument as before.
        if ~isempty(whichDocTopic) && ~isequal(whichDocTopic,docTopic)
            success = showTopic(whichDocTopic, isMethodOrProp);
        end
    end
end
end

function [topic, isMethodOrProp] = getClassInformation(topic)
try
    isMethodOrProp = false;
    try
        classInfo = helpUtils.splitClassInformation(topic, '', true, false);
    catch
        classInfo = helpUtils.splitClassInformation(topic, '', false);
    end
    topic = [];
    if ~isempty(classInfo)
        try
            isMethodOrProp = classInfo.isMethod || classInfo.isProperty;
            topic = classInfo.getDocTopic(false);
        catch
            isElement = classInfo.isMethod || classInfo.isSimpleElement;
            topic = classInfo.getDocTopic(false);
        end
    end
catch
    classResolver = matlab.internal.language.introspective.resolveName(topic, '', false);
    classInfo     = classResolver.classInfo;
    
    isMethodOrProp = false;
    topic     = [];
    
    if ~isempty(classInfo)
        isMethodOrProp = classInfo.isMethod || classInfo.isSimpleElement;
        topic = classInfo.getDocTopic(false);
    end
end
end


function success = showTopic(topic, isMethodOrProp)
    topicParts = getTopicParts(topic);
    if isempty(topicParts)
        success = false;
    elseif ~isempty(topicParts.dir)
        % Case topic path specified, e.g., symbolic/diag.
        fullTopic = [topicParts.dir '/' topicParts.name];
        success = showReferencePage(fullTopic, isMethodOrProp);
        if ~success
            fullTopic = [topicParts.dir '.' topicParts.name];
            success = showReferencePage(fullTopic, isMethodOrProp);
        end
    else
        % Case toolbox path not specified.
        % Check for product page first.  Otherwise,
        % search for all instances of this topic in the help hierarchy.
        % Display the first instance found and list the others
        % in the MATLAB command window.
        
        % Show the product page if that's what they're asking for...
        success = showProductPage(topicParts.name);
        if ~success
            % Show the reference page for the topic.
            success = showReferencePage(topicParts.name, isMethodOrProp);
        end
    end
end

% Helper function that splits up the topic into a topic directory, and a
% topic name.
function parts = getTopicParts(topic)
    parts = regexp(topic,'^(?<dir>[^\\/]*(?=[\\/]\w))?[\\/]?(?<name>(\W+|[^\\/]+))[\\/]?$','names');
    if isempty(parts)
        [path, name] = fileparts(topic);
        topic = helpUtils.getDocTopic(path, name, false);
        if ~isempty(topic)
            parts = regexp(topic,'^(?<dir>[^\\/]*(?=[\\/]\w))?[\\/]?(?<name>(\W+|[^\\/]+))[\\/]?$','names');
        end
    end
    if ~isempty(parts)
        parts.name = lower(parts.name);
        parts.name = regexprep(parts.name,'[\s-\(\)]|\.m$','');
    end
end

% Helper function that shows the reference page, displaying any overloaded
% functions or blocks in the command window.
function success = showReferencePage(topic, isMethodOrProp)
    success = com.mathworks.mlservices.MLHelpServices.showReferencePage(topic, isMethodOrProp);
end

% Helper function used to display the product page, used when the topic
% is the short name of a product.
function success = showProductPage(topic)
    product = com.mathworks.mlwidgets.help.HelpInfo.getHelpInfoItemByShortName(topic);
    if ~isempty(product)
        success = com.mathworks.mlservices.MLHelpServices.showProductPage(topic);
    else
        success = false;
    end
end

% Helper function used to display the error page when no reference page
% was found for the topic.
function showNoReferencePageFound(topic)
    noFuncPage = helpUtils.underDocroot('nofunc.html');
    if ~isempty(noFuncPage)
        displayFile(noFuncPage);
    else
        error(message('MATLAB:doc:InvalidTopic', topic));
    end
end

% Helper function used to show the topic help using helpwin.
function foundTopic = showHelpwin(topic)
    % turn off the warning message about helpwin being removed in a future
    % release
    s = warning('off', 'MATLAB:helpwin:FunctionToBeRemoved');
    
    foundTopic = helpwin(topic, '', '', '-doc');
    
    % turn the warning message back on if it was on to begin with
    warning(s.state, 'MATLAB:helpwin:FunctionToBeRemoved');
end

%------------------------------------------
% Helper function that displays the HTML file in the appropriate browser.
function displayFile(htmlFile)
    % Display the file inside the help browser.
    web(htmlFile, '-helpbrowser');
end