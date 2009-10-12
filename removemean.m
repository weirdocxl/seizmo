function [data]=removemean(data)
%REMOVEMEAN    Remove mean from SEIZMO records
%
%    Usage:    data=removemean(data)
%
%    Description: REMOVEMEAN(DATA) removes the mean from SEIZMO records.
%     In the case of multi-component records, each component has the mean
%     removed.
%
%    Notes:
%     - useful for avoiding edge-effects in spectral operations but
%       REMOVETREND is probably a better option in this case
%
%    Header changes: DEPMEN, DEPMIN, DEPMAX
%
%    Examples:
%     It is generally a good idea to remove the mean from records before
%     performing any filtering operations to avoid edge effects:
%      plot1(squish(data,5))             % more ringing
%      plot1(squish(removemean(data),5)) % less ringing
%
%    See also: REMOVETREND, REMOVEPOLYNOMIAL, GETPOLYNOMIAL, TAPER,
%              REMOVEDEADRECORDS

%     Version History:
%        Oct. 31, 2007 - initial version
%        Nov.  7, 2007 - doc update
%        Nov. 27, 2007 - minor doc update
%        Feb. 29, 2008 - SEISCHK support
%        Mar.  4, 2008 - minor doc update
%        May  12, 2008 - fix dep* formula
%        June 12, 2008 - doc update, history added
%        Oct.  3, 2008 - .dep & .ind
%        Nov. 22, 2008 - doc update, rename from RMEAN to REMOVEMEAN
%        Apr. 23, 2009 - fix nargchk and seizmocheck for octave,
%                        move usage up
%        June 24, 2009 - minor doc fix
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Aug. 17, 2009 at 20:30 GMT

% todo:

% check input
msg=nargchk(1,1,nargin);
if(~isempty(msg)); error(msg); end

% check data structure
msg=seizmocheck(data,'dep');
if(~isempty(msg)); error(msg.identifier,msg.message); end

% turn off struct checking
oldseizmocheckstate=get_seizmocheck_state;
set_seizmocheck_state(false);

% number of records
nrecs=numel(data);

% remove mean and update header
depmen=nan(nrecs,1); depmin=depmen; depmax=depmen;
for i=1:nrecs
    % skip dataless
    if(isempty(data(i).dep)); continue; end
    
    % save class and convert to double precision
    oclass=str2func(class(data(i).dep));
    data(i).dep=double(data(i).dep);
    
    % loop through components
    for j=1:size(data(i).dep,2)
        data(i).dep(:,j)=data(i).dep(:,j)-mean(data(i).dep(:,j));
    end
    
    % change class back
    data(i).dep=oclass(data(i).dep);
    
    % adjust header
    depmen(i)=mean(data(i).dep(:));
    depmin(i)=min(data(i).dep(:)); 
    depmax(i)=max(data(i).dep(:));
end

% adjust header
data=changeheader(data,'depmen',depmen,'depmin',depmin,'depmax',depmax);

% toggle checking back
set_seizmocheck_state(oldseizmocheckstate);

end
