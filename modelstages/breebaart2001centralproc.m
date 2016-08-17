function decision = breebaart2001centralproc(EI_map,monol,monor,bimonostring,monofactor)

if nargin == 4
    monofactor = 0.0003;
end

persistent maskernumber;
persistent signalnumber;

intnum = length(EI_map);
tempsize = size(EI_map{1});
intnoisevar = 1;
binauralset = 0;
monolset = 0;
monorset = 0;

if isempty(maskernumber)
    maskernumber = intnum-1;
    signalnumber = 1;
else
    maskernumber = maskernumber+intnum-1;
    signalnumber = signalnumber + 1;
end
 
% binaural wanted
if strfind(lower(bimonostring),'b')
    binauralset = 1;
    persistent template; 
    persistent templatesq;
    persistent signaltemplate;
    U_b = zeros(1,intnum);
    
    if maskernumber == 2
        template = zeros(tempsize);
        templatesq = zeros(tempsize);
        signaltemplate = zeros(tempsize);
    end
    
    noisevar = templatesq - template.^2;
    meandiff = signaltemplate - template;
    weight = meandiff./(noisevar + intnoisevar);
    Nuvar = intnoisevar*sum(sum(weight.^2));        
end

% left mono channel wanted
if strfind(lower(bimonostring),'l')
    monolset = 1;
    persistent template_ml;
    persistent templatesq_ml;
    persistent signaltemplate_ml;
    monol = cellfun(@(x) x*monofactor,monol,'un',0);
    U_ml = zeros(1,intnum);
    
    if maskernumber == 2
        template_ml = zeros(tempsize);
        templatesq_ml = zeros(tempsize);
        signaltemplate_ml = zeros(tempsize);
    end
    
    noisevar_ml = templatesq_ml - template_ml.^2;
    meandiff_ml = signaltemplate_ml - template_ml;
    weight_ml = meandiff_ml./(noisevar_ml + intnoisevar);
    Nuvar_ml = intnoisevar*sum(sum(weight_ml.^2));
end

% right mono channel wanted
if strfind(lower(bimonostring),'r')
    monorset = 1;
    persistent template_mr;
    persistent templatesq_mr;
    persistent signaltemplate_mr;
    monor = cellfun(@(x) x*monofactor,monor,'un',0);
    U_mr = zeros(1,intnum);
    
    if maskernumber == 2
        template_mr= zeros(tempsize);
        templatesq_mr = zeros(tempsize);
        signaltemplate_mr = zeros(tempsize);
    end
    
    noisevar_mr = templatesq_mr - template_mr.^2;
    meandiff_mr = signaltemplate_mr - template_mr;
    weight_mr = meandiff_mr./(noisevar_mr + intnoisevar);
    Nuvar_mr = intnoisevar*sum(sum(weight_mr.^2));
end


for intcount = 1:intnum
    noise = randn;
    if binauralset == 1
        U_b(intcount) = sum(sum(weight.*(EI_map{intcount}-template)))...
            + noise*sqrt(Nuvar);
    end
    if monolset == 1
        U_ml(intcount) = sum(sum(weight_ml.*(monol{intcount}-template_ml)))...
            + noise*sqrt(Nuvar_ml);
    end
    if monorset ==1
        U_mr(intcount) = sum(sum(weight_mr.*(monor{intcount}-template_mr)))...
            + noise*sqrt(Nuvar_mr);
    end
end

% take binaural, mono left and mono right
if binauralset && monolset && monorset
    % binaural decision is empty and no big B
    if signalnumber > 1 && any(U_b) == 0 && ~isempty(strfind(bimonostring,'b')) 
        U = mean([U_ml;U_mr]);
    else
        U = mean([U_b;U_ml;U_mr]);
    end
% take binaural and mono left
elseif binauralset && monolset
    U = mean([U_b;U_ml]);
% take binaural and mono right
elseif binauralset && monorset
    U = mean([U_b;U_mr]);
% take mono left and mono right
elseif monorset && monolset
    U = mean([U_ml;U_mr]);
% take binaural
elseif binauralset
    U = U_b;
% take mono left
elseif monolset
    U = U_ml;
% take mono right
elseif monorset
    U = U_mr;
end
    
% If centralproc is called the first time, all the templates are empty
% In this case the results of U will be zeros. Therefore the response
% of max(U) will always be 1 = first occurence of 0.
[~,response] = max(U);


if binauralset
    % update of templates
    signaltemplate = ((signaltemplate*(signalnumber-1))+...
        (EI_map{1}))./signalnumber;
    
    % binaural test
    [~,response_b] = max(U_b);
    if response_b ~= response && any(U_b) == 1
        amtdisp(sprintf(['binaural decision is not the same: '...
            'signalnumber %i, response = %i, binaural response = %i \n'],...
            signalnumber,response,response_b));
    end
    adtemplate = zeros(tempsize);
    adtemplatesq = zeros(tempsize);
    
    for updatecounter = 2:intnum
        adtemplate = adtemplate + EI_map{updatecounter};
        adtemplatesq = adtemplatesq + EI_map{updatecounter}.^2;
    end
    
    template = ((template*(maskernumber-(intnum-1)))...
        +(adtemplate))./maskernumber;
    templatesq = ((templatesq*(maskernumber-(intnum-1)))+...
        (adtemplatesq).^2)./maskernumber; 
end

if monolset
   % update of templates 
    signaltemplate_ml = ((signaltemplate_ml*(signalnumber-1))+...
        (monol{1}))./signalnumber;
    adtemplate_ml = zeros(tempsize);
    adtemplatesq_ml = zeros(tempsize);
    
    for updatecounter = 2:intnum
        adtemplate_ml = adtemplate_ml + monol{updatecounter};
        adtemplatesq_ml = adtemplatesq_ml + monol{updatecounter}.^2;
    end
    
    template_ml = ((template_ml*(maskernumber-(intnum-1)))...
        +(adtemplate_ml))./maskernumber;
    templatesq_ml = ((templatesq_ml*(maskernumber-(intnum-1)))...
        +(adtemplatesq_ml).^2)./maskernumber; 
end

if monorset
   % update of templates
   signaltemplate_mr = ((signaltemplate_mr*(signalnumber-1))+...
       (monor{1}))./signalnumber;
   adtemplate_mr = zeros(tempsize);
   adtemplatesq_mr = zeros(tempsize);
   
   for updatecounter = 2:intnum
       adtemplate_mr = adtemplate_mr + monor{updatecounter};
       adtemplatesq_mr = adtemplatesq_mr + monor{updatecounter}.^2;
   end
   
   template_mr = ((template_mr*(maskernumber-(intnum-1)))+...
       (adtemplate_mr))./maskernumber;
   templatesq_mr = ((templatesq_mr*(maskernumber-(intnum-1)))+...
       (adtemplatesq_mr).^2)./maskernumber; 
end

decision = response;