function [] = Financial_Model(n_agents, n_items, price, nbrands, rndbrand)

agent = struct ('money', 0, 'soc_stat', 0, 'items', 0, 'desire', 0, 'mode', 0, 'buysell', 0, 'sprice', 0, 'bprice', 0, 'bought', 0, 'sold', 0, 'keep', 0);
seller = struct ('money', 0, 'nitems', 0, 'socstat', 0, 'bprice', 0, 'sold', 0, 'mode', 0, 'initmoney', 0, 'brand', 0);
buyer = struct ('money', 0, 'nitems', 0, 'socstat', 0, 'desire', 0, 'bprice', 0, 'bought', 0, 'mode', 0, 'initmoney', 0, 'keep', 0, 'bdes', 0);
full = struct ('money', 0, 'nitems', 0, 'socstat', 0, 'mode', 0, 'initmoney', 0);
brnd = struct ('price', 0, 'socstat', 0);
% prob array has the following structure: 1 - set, 2 - soc, 3 - prof, 4 -
% coll
% The brand variable takes into account from which brand is the setter
% selling the shoes. 0 - would be for independent sellers (The socialitees
% and profiteers that are selling something)
% The keep variable is only used by the collector to know if they will sell
% their stuff in order to get the new released items
%The field initmoney is just only by the profiteers to know when they have
%achieved their goal of maximizing their money

%Mode indicates if the agent is a setter, socialitee, collector or
%profiteer. 1 - set, 2 - soc, 3 - col, 4 - prof

%Buysell indicates if the agent is a seller or a buyer. 0 - Seller 1 -
%Buyer

% The desire parameters measures how much the agent wants to buy the item.
% For socialitees this value will be higher, and for profiteers &
% collectors it will be smaller, but the collectors' value will rise as
% time goes on because items will be more appreciated. For trendsetters
% this value will be 0, since they do not want to buy their own stuff
if rndbrand == 0 %The prices and social status of the brand are not randomly set, they are hard coded
    nbrands = 4;
end
items_soc = repmat(1, n_items, 1); % We need to give each item a social status, so that the person that owns it has the social status attached to it. 
people = repmat(agent, n_agents, 1);
brand = repmat(brnd, nbrands, 1);
total = 0;
n_soc = 0; n_prof = 0; n_coll = 0; n_set = 0;

while(n_soc<=0 || n_prof<=0 || n_coll<=0 || n_set<=0)
n_set = randi([round(n_agents*0.1), round(n_agents*0.15)]);
n_soc = randi([round(n_agents*0.25), round(n_agents*0.6)]);
n_prof = randi([round(n_agents*0.2), round(n_agents*0.5)]);
n_coll = n_agents - n_prof - n_soc - n_set;
end

% Assign the sellers to each brand
for i=1:nbrands
   sperbrand(i) = round(n_set/nbrands);
   exsel = mod(n_set, nbrands);
end
index = 0;
for i=1:exsel
    index = mod(i, nbrands);
    sperbrand(index) = sperbrand(index) + 1;
end
el = 0;
for i=1:nbrands-1
    el = round((rand*2-1)*round(n_set/(3*nbrands)));
    sperbrand(i) = sperbrand(i) - el;
    sperbrand(i+1) = sperbrand(i+1) + el;
end
tset = sum(sperbrand);
if tset > n_set
   for i=1:tset-n_set
      index = mod(i, nbrands)+1;
      sperbrand(index) = sperbrand(index) - 1;
   end
end
if tset < n_set
   for i=1:n_set-tset
      index = mod(i, nbrands)+1;
      sperbrand(index) = sperbrand(index) + 1;
   end
end
keyboard;

sellers = repmat(seller, n_set, 1);
buyers = repmat(buyer, (n_agents-n_set), 1);
fulfill = repmat(full, 2, 1);

%% Initialize the number of items each agent has and the money they have
el_items = 0;
nitems = n_items;

for i=1:n_set % Assign values to the trendsetters
   people(i).money = (randi([2, 10])/10)*10e6;
   people(i).nitems = round(n_items/n_set) - 1;
   el_items = el_items + people(i).items;
   people(i).soc_stat = randi([80, 100]);
   people(i).desire = 0; % Trendsetters have no desire to buy their own goods
   people(i).mode = 1;
   people(i).buysell = 0;
end

n_items = n_items - el_items;
while n_items > 0
    p = randi([1 n_set]);
    people(p).nitems = people(p).nitems + 1;
    n_items = n_items - 1;
end

for i=n_set+1:n_set+n_soc % Assign values to the socialitees
   people(i).money = (randi([15, 25]))*1e2;
   people(i).nitems = 0;
   people(i).soc_stat = randi([5, 20]);
   people(i).desire = rand()*30+70;
   people(i).mode = 2;
   people(i).buysell = 1;
end

for i=n_set+n_soc+1:n_set+n_soc+n_coll % Assign the values to the collectors
    people(i).money = (randi([15, 25]))*1e2;
    people(i).nitems = 0;
    people(i).soc_stat = randi([5, 20]);
    people(i).desire = rand()*5;
    people(i).mode = 3;
    people(i).buysell = 1;
    people(i).keep = rand();
end

for i=n_set+n_soc+n_coll+1:n_agents % Assign the values to the profiteers
   people(i).money = (randi([15, 25]))*1e2;
   people(i).nitems = 0;
   people(i).soc_stat = randi([5, 20]);
   people(i).desire = rand()*20+50;
   people(i).mode = 4;
   people(i).buysell = 1;
end

% Assign social status to each item

item_index = 1;

for i=1:n_agents
   for j=1:people(i).nitems 
       items_soc(item_index) = randi([8, 10])*people(i).soc_stat/10;
       item_index = item_index + 1;
   end
end

%% Put items for sale and make the socialitees, profiteers and collectors buy and sell.
% Check the number of sellers & buyers and assign the selles & buyers (sellers = setters & buyers = everyone else in
% the beginning)
nsell = 0;
nbuy = 0;
for i=1:n_agents
   if people(i).buysell == 0
      nsell = nsell + 1;
      sellers(nsell).money = people(i).money;
      sellers(nsell).nitems = people(i).nitems;
      sellers(nsell).socstat = people(i).soc_stat;
      sellers(nsell).mode = people(i).mode;
      sellers(nsell).initmoney = people(i).money;
   else
       nbuy = nbuy + 1;
       buyers(nbuy).money = people(i).money;
       buyers(nbuy).nitems = people(i).nitems;
       buyers(nbuy).socstat = people(i).soc_stat;
       buyers(nbuy).mode = people(i).mode;
       buyers(nbuy).desire = people(i).desire;
       buyers(nbuy).keep = people(i).keep;
       buyers(nbuy).bsoc = people(i).soc_stat;
       buyers(nbuy).bdes = people(i).desire;
       buyers(nbuy).initmoney = people(i).money;
   end
end
% Set a price and social status
if rndbrand == 1 %We assign the prices adn stuff randomly
    for i=1:nbrands
       brand(i).price = randi([300 600]);
       brand(i).socstat = randi([70 100]);
    end
end
if rndbrand == 0
   brand(1).price = 300;
   brand(1).socstat = 75;
   brand(2).price = 375;
   brand(2).socstat = 82;
   brand(3).price = 450;
   brand(3).socstat = 89;
   brand(4).price = 550;
   brand(4).price = 95;
end

% Put the brand to each seller (setter)
h = 0;
w = 0;
for i=1:nbrands
    h = h + sperbrand(i);
   for j=1+w:h
      sellers(j).brand = i; 
   end
   w = h;
end
keyboard;
sigmaprice = 0.05;
ks = 2.5; %constant for the standard deviation for the selling and buying limit prices
sigma = ks*sigmaprice;
for i=1:n_set
    for j=1:nbrands
       if sellers(i).brand == j
           for k=1:sellers(i).nitems
              sellers(i).items(k).price = brand(j).price*brand(j).socstat/80; 
              sellers(i).items(k).socstat = normrnd(sellers(i).socstat, 0.5);
              sellers(i).items(k).sold = 0;
              sellers(i).items(k).time = 0; %This controls when was de object introduced.
              sellers(i).items(k).brand = sellers(i).brand;
           end
       end
    end
end
keyboard;


% The probability of a socialitees buying an item depends on the social
% status of the trendsetter that owns the item. Therefore, we need to make
% that the trendsetters with lower social status put their items for sale
% with a lower price so that they get bought

T = 20; %number of iterations for the time window for the sigma calculation
Pc = 0.7; %probability an item is bought or sold (If a random number is higher than this value, then the item will be bought. If it is lower, it won't be bought
sellpos = nsell; %This variable checks if there is any seller with items to sell
buypos = nbuy; % This variable checks if there is any buyer with enough money to buy
i = 0; % Checks the amount of iterations
lowp = 120; %How much we lower the selling and buying prices of the agents who bought or sold something
highp = 60; %How much we increase the prices in case the agent didn't do anything
nful = 0;
newitem = 50; %How frequent we insert new items into the model

%     for j=1:nsell %Go through all the sellers and assign them their sell prices
%        sellers(j).sprice = (price*(sellers(j).socstat/40))/normrnd(1.01, sigma);
%     end
    for j=1:nbuy %Go through all the buyers and assign them their buy prices
        buyers(j).bprice = price*normrnd(1.01, sigma)*buyers(j).desire/100; %This buying price gets affected by the desire of each agent to buy the good
    end
    
%% Iterate

while ~isempty(sellers) && ~isempty(buyers) && i<500
    
    i = i + 1;
    for j=1:nbuy
       if buyers(j).mode == 3 %They are collectors and their desire is not already superstrong
          buyers(j).desire = min(buyers(j).desire + rand()*10, 100); % Make the collectors desire increase as time progresses
       end
    end
    
    for j=1:nbuy
       buyers(j).bprice = min(buyers(j).money, buyers(j).bprice); 
    end
    
        spriceavg = 0;
    bpriceavgsoc = 0;
    bpriceavgcoll = 0;
    bpriceavgprof = 0;
    
    % Get the average buying and selling prices
    a = 0;
    c = 0;
    b = 0;
    d = 0;
    avgt(i, :) = zeros(1, floor(i/newitem)+1);
    avgb(i, :) = zeros(1, nbrands);
    ipt(i, :) = zeros(1, floor(i/newitem)+1);
    ipb(i, :) = zeros(1, nbrands);
    u = 0;
    for j=1:length(sellers)
        for k=1:sellers(j).nitems
           spriceavg = spriceavg +  sellers(j).items(k).price; 
           u = u + 1;
           avgt(i, sellers(j).items(k).time+1) = avgt(i, sellers(j).items(k).time+1) + sellers(j).items(k).price;
           ipt(i, sellers(j).items(k).time+1) = ipt(i, sellers(j).items(k).time+1) + 1; %Items per time
           avgb(i, sellers(j).items(k).brand) = avgb(i, sellers(j).items(k).brand) + sellers(j).items(k).price;
           ipb(i, sellers(j).items(k).brand) = ipb(i, sellers(j).items(k).brand) + 1; %Items per brand
        end
    end
    spriceavg = spriceavg/u;
    for j=1:length(buyers)
        if buyers(j).mode == 2
            c = c + 1;
            bpriceavgsoc = bpriceavgsoc + buyers(j).bprice;
        end
        if buyers(j).mode == 3
            a = a + 1;
           bpriceavgcoll = bpriceavgcoll + buyers(j).bprice; 
        end
        if buyers(j).mode == 4
            b = b + 1;
           bpriceavgprof = bpriceavgprof + buyers(j).bprice; 
        end

    end
    
    for j=1:size(avgt, 2)
        avgt(i, j) = avgt(i, j)./ipt(i, j);
    end
    for j=1:size(avgb, 2)
       avgb(i, j) = avgb(i, j)./ipb(i, j); 
    end
    bpriceavgsoc = bpriceavgsoc/c;
    bpriceavgprof = bpriceavgprof/b;
    bpriceavgcoll = bpriceavgcoll/a;
    
    avg(i, 1) = spriceavg;
    avg(i, 2) = bpriceavgsoc;
    avg(i, 3) = bpriceavgcoll;
    avg(i, 4) = bpriceavgprof;
    iter(i) = i;
    
%     keyboard;
    % Compare buying & selling prices and determine whether a purchase is
    % made or not based on a probability
    for k=1:nsell % loop over all the sellers and see if any buying price is below the associated selling price
       for j=1:nbuy % Loop over the buyers & as soon as someone buys from the seller, stop the iteration
           for  h=1:sellers(k).nitems  
               if (buyers(j).bprice>=sellers(k).items(h).price && rand()>Pc && buyers(j).bought == 0)
                   if rand()<(sellers(k).items(h).socstat/100)
%                    if buyers(j).mode ~= 3 % If the buyer is not a collector, everything works fine
                       % If there is a purchase, remove the item from the seller &
                       % put it in the buyer. Subtract the money used for buying
                       % from the buyer account & put it in the seller account
                       sellers(k).nitems = sellers(k).nitems - 1;
                       buyers(j).nitems = buyers(j).nitems + 1;
                       %Assign a random proportion of the social status from the
                       %seller to the buyer as they buy something from someone with
                       %social status
%                        buyers(j).socstat = buyers(j).socstat + (rand()*0.15+0.1)*sellers(k).items(h).socstat;
%                        % If a socialitee sells one of the items, he loses social
%                        % status
%                        if sellers(k).mode ~= 1 % If the seller is not a setter, who won't lose its social status
%                            sellers(k).socstat = sellers(k).socstat - (rand()*0.15+0.1)*sellers(k).items(h).socstat;
%                        end
                       soldprice = (buyers(j).bprice+sellers(k).items(h).price)/2; 
                       buyers(j).money = buyers(j).money - soldprice;
                       sellers(k).money = sellers(k).money + soldprice;
                       buyers(j).items(buyers(j).nitems).socstat = normrnd(sellers(k).items(h).socstat, 1);
                       buyers(j).items(buyers(j).nitems).brand = sellers(k).items(h).brand;
                       buyers(j).items(buyers(j).nitems).time = sellers(k).items(h).time;
                       if buyers(j).mode ~= 4
                         buyers(j).items(buyers(j).nitems).price = buyers(j).bprice + (rand()*2-1)*buyers(j).items(buyers(j).nitems).socstat*5;
                       end
                       if buyers(j).mode == 4
                           buyers(j).items(buyers(j).nitems).price = buyers(j).bprice + (rand())*buyers(j).items(buyers(j).nitems).socstat*3;
                       end
                       buyers(j).bought = 1; %Set a flag so that that buyer doesn't buy anymore this iteration
                       sellers(k).sold = 1; %Set a flag to know that the seller has sold
                       sellers(k).items(h) = [];
%                        keyboard;
                       break;
%                    else
                       % if sellers(k).mode ~= 1 % If the seller is not a setter, the collector is not interested in the item
                       % else % If the seller is a setter, then the collector will buy
%                            sellers(k).nitems = sellers(k).nitems - 1;
%                            buyers(j).nitems = buyers(j).nitems + 1;
%                            soldprice = (buyers(j).bprice+sellers(k).items(h).price)/2; 
%                            buyers(j).money = buyers(j).money - soldprice;
%                            sellers(k).money = sellers(k).money + soldprice;
%                            %Assign the item to the buyer
%                            buyers(j).items(buyers(j).nitems).socstat = sellers(k).items(h).socstat;
%                            %
%                            buyers(j).bought = 1; %Set a flag so that that buyer doesn't buy anymore this iteration
%                            sellers(k).sold = 1; %Set a flag to know that the seller has sold
% %                            buyers(j).items
%                            sellers(k).items(h) = [];
%                            break;
                       %end
                   end
                end
               end
           end
       end
%     end
%     keyboard;

   % Adjust the price in each agent depending on whether they bought or
   % sold or not
   for j=1:length(sellers)
      for k=1:sellers(j).nitems
          if sellers(j).items(k).sold == 0
              sellers(j).items(k).price = sellers(j).items(k).price - 120;
              if sellers(j).mode == 4
                  sellers(j).items(k).price = max(sellers(j).bprice, sellers(j).items(k).price);
                  % Profiteers won't sell it lower than what they bought it
                  % for, they don't want to lose money
              end
          end
      end
   end
    
    %The desire of collectors is reseted once they buy something
    for j=1:length(buyers)
        if buyers(j).mode == 3 && buyers(j).bought == 1
            buyers(j).desire = rand()*20+10;
        end
    end
    %Calculate social status based on the items they have and how much
    %social status these items have
    
    for j=1:length(buyers)
        buyers(j).socstat = buyers(j).bsoc;
           for k=1:buyers(j).nitems
              buyers(j).socstat = buyers(j).socstat + 0.2*buyers(j).items(k).socstat; 
           end
    end
    for j=1:length(sellers)
        if sellers(j).mode ~= 1
            sellers(j).socstat = sellers(j).bsoc;
           for k=1:sellers(j).nitems
              sellers(j).socstat = sellers(j).socstat + 0.2*sellers(j).items(k).socstat; 
           end
        end
    end
%     keyboard;
    
    % The desire of the socialitees decreases as the have more socstat. But
    % in increases when they have less social status. For the profiteers,
    % the desire goes with the difference between their initial money and
    % their money now
    for j=1:length(buyers)
        if buyers(j).mode == 2 %Only if they are socialitees
            buyers(j).desire = buyers(j).bdes + (buyers(j).bsoc - buyers(j).socstat)*0.8;
        end
        if buyers(j).mode == 4 %Only the profiteers
            buyers(j).desire = buyers(j).bdes - (buyers(j).money - buyers(j).initmoney)*0.01;
        end
        buyers(j).desire = max(buyers(j).desire, 0);
        buyers(j).desire = min(buyers(j).desire, 100);
    end
    for j=1:length(sellers)
        if sellers(j).mode == 2 %Only if they are socialitees
            sellers(j).desire = sellers(j).bdes + (sellers(j).bsoc - sellers(j).socstat)*0.8;
            sellers(j).desire = max(sellers(j).desire, 0);
            sellers(j).desire = min(sellers(j).desire, 100);
        end
        if sellers(j).mode == 4 %Only the profiteers
            sellers(j).desire = sellers(j).bdes - (sellers(j).money - sellers(j).initmoney)*0.01;
            sellers(j).desire = max(sellers(j).desire, 0);
            sellers(j).desire = min(sellers(j).desire, 100);
        end
    end

    % Change all the buyers that do not have enough money (based on the avg
    % selling price) and make them sellers. Collectors do not become
    % sellers, as they don't want to sell. 
    k = 0; %k indicates the amount of buyers that have to be deleted
    svindex = []; %Saves the indices that have to be deleted
    nsell = length(sellers);
    nbuy = length(buyers);
    for j=1:nbuy
       if buyers(j).money < price && buyers(j).nitems > 0 && buyers(j).mode ~= 3
           k = k + 1;
           sellers(nsell+k).money = buyers(j).money;
           sellers(nsell+k).socstat = buyers(j).socstat;
           sellers(nsell+k).nitems = buyers(j).nitems;
           sellers(nsell+k).bprice = buyers(j).bprice; %This is so sellers remember the price they bought the item for
           sellers(nsell+k).items = buyers(j).items;
           for h=1:buyers(j).nitems 
              sellers(nsell+k).items(h).sold = 0;
           end
           sellers(nsell+k).mode = buyers(j).mode;
           sellers(nsell+k).initmoney = buyers(j).initmoney;
           sellers(nsell+k).bsoc = buyers(j).bsoc;
           sellers(nsell+k).bdes = buyers(j).bdes;
           % sellers(nsell+k).sprice = (price*(sellers(nsell+k).socstat/30))/normrnd(1.01, sigma);
           sellers(nsell+k).sold = 0; 
           svindex(k) = j; %Store the index of the buyer that has to be deleted
       end
    end
%     keyboard;
    for j=1:k
        h = svindex(k-j+1);
        buyers(h) = [];
    end
    nbuy = nbuy - k;
    nsell = nsell + k;
%     keyboard;
    % Now check if any of the sellers who are not a setter has no items and
    % make them buyers. nsell is updated with the new amount of sellers,
    % but it should not change the buyers who just became sellers, as they
    % would have items, if everything worked correctly
    k = 0;
    svindex = [];
    nsell = length(sellers);
    nbuy = length(buyers);
    for j=1:nsell
       if sellers(j).nitems == 0 && sellers(j).mode ~= 1 
          k = k + 1;
          buyers(nbuy+k).money = sellers(j).money;
          buyers(nbuy+k).nitems = sellers(j).nitems;
          buyers(nbuy+k).socstat = sellers(j).socstat;
          buyers(nbuy+k).mode = sellers(j).mode;
          buyers(nbuy+k).items = sellers(j).items;
          buyers(nbuy+k).initmoney = sellers(j).initmoney;
          buyers(nbuy+k).bought = 0;
          buyers(nbuy+k).bdes = sellers(j).bdes;
          buyers(nbuy+k).bprice = price*normrnd(1.01, sigma);
          if sellers(j).mode == 2 %The seller is a socialitee
              buyers(nbuy+k).desire = rand()*30+70; 
              
          end
          if sellers(j).mode == 4 %The seller is a collector
              buyers(nbuy+k).desire = rand()*20+50; 
          end
          buyers(nbuy+k).bsoc = sellers(j).bsoc;
          svindex(k) = j;
       end
    end
    for j=1:k
        h = svindex(k-j+1);
        sellers(h) = [];
    end
    nbuy = nbuy + k;
    nsell = nsell - k;
%     keyboard;
    
   for j=1:nbuy
      if buyers(j).bought == 0
         buyers(j).bprice = buyers(j).bprice + normrnd(highp*buyers(j).desire, 90)/50;
      else
         buyers(j).bprice = buyers(j).bprice - normrnd(lowp/buyers(j).desire, 0.1)*50;
      end
   end
%    keyboard;
   
   for j=1:nbuy
       buyers(j).bought = 0; %Restart the bought flag for the next iteration
   end
   for j=1:nsell
      sellers(j).sold = 0; % Restart the sold flag for the next iteration
   end
   % Check that at least one seller has items to sell & at least one buyer
   % has money to buy
   sellpos = 0;
   buypos = 0;   
   %Check if any of the agents have fulfilled their dreams (socialitees
   %have increased their social status, collectors have done something,
   %profiteers have increased their original amount of money a 10%
   k = 0;
   svindex = [];
%    for j=1:nbuy
%       if buyers(j).mode == 2 && buyers(j).socstat >= 70 %Check that the buyers are soc and their socstat is higher than a threshold
%          k = k + 1;
%           fulfill(nful+k).money = buyers(j).money;
%          fulfill(nful+k).socstat = buyers(j).socstat;
%          fulfill(nful+k).items = buyers(j).items;
%          fulfill(nful+k).mode = buyers(j).mode;
%          fulfill(nful+k).initmoney = buyers(j).initmoney;
%          svindex(k) = j;
%       end
%       if buyers(j).mode == 4 && buyers(j).money >= 1.1*buyers(j).initmoney %They are profiteers and have increased the money they initially had
%          k = k + 1;
%           fulfill(nful+k).money = buyers(j).money;
%          fulfill(nful+k).socstat = buyers(j).socstat;
%          fulfill(nful+k).items = buyers(j).items;
%          fulfill(nful+k).mode = buyers(j).mode;
%          fulfill(nful+k).initmoney = buyers(j).initmoney;
%          svindex(k) = j;
%       end
%       if buyers(j).mode == 3 && buyers(j).money <= price && buyers(j).items > 0
%           k = k + 1;
%           fulfill(nful+k).money = buyers(j).money;
%           fulfill(nful+k).items = buyers(j).items;
%           fulfill(nful+k).socstat = buyers(j).socstat;
%           fulfill(nful+k).mode = buyers(j).mode;
%           fulfill(nful+k).initmoney = buyers(j).initmoney;
%           svindex(k) = j;
%       end
%    end
%     for j=1:k
%         h = svindex(k-j+1);
%         buyers(h) = [];
%     end
%     nbuy = nbuy - k;
    % Give some money to the people that don't have enough money, as if they
    % earned money in their jobs
    
    for j=1:length(buyers)
       if buyers(j).money < price*2 && buyers(j).bought == 0
          buyers(j).money = buyers(j).money + 120;
       end
    end
%     keyboard;
    %Check if an seller is ready to leave the game with the same procedure
    z = 0;
    w = 0;
    svindex = [];
    
    % No removing people
%     for j=1:nsell
%        if sellers(j).mode == 2 && sellers(j).socstat >= 70 %A socialitee with a higher social status
%            z = z + 1;
%           fulfill(nful+k+z).money = sellers(j).money;
%           fulfill(nful+k+z).items = sellers(j).items;
%           fulfill(nful+k+z).socstat = sellers(j).socstat;
%           fulfill(nful+k+z).mode = sellers(j).mode;
%           fulfill(nful+k+z).initmoney = sellers(k+z).initmoney;
%           svindex(z+w) = j;
%        end
%        if sellers(j).mode == 4 && sellers(j).money >= 1.1*sellers(j).initmoney %A profiteer with more money than the initial one
%            z = z + 1;
%           fulfill(nful+k+z).money = sellers(j).money;
%           fulfill(nful+k+z).items = sellers(j).items;
%           fulfill(nful+k+z).socstat = sellers(j).socstat;
%           fulfill(nful+k+z).mode = sellers(j).mode;
%           fulfill(nful+k+z).initmoney = sellers(k+z).initmoney;
%           svindex(z+w) = j;
%        end
%        if sellers(j).mode == 1 && sellers(j).items == 0
%           w = w + 1;
%           svindex(z+w) = j;
%        end
%     end
%     for j=1:z+w
%         h = svindex(z+w-j+1);
%         sellers(h) = [];
%     end
%     nsell = nsell - z - w;
%     keyboard;
    %Get the number of already fulfilled agents for the next iteration
    
    [nful uno] = size(fulfill);
    
    if ~isempty(sellers) && ~isempty(buyers)
        buypos = 0;
        sellpos = 0;
           for j=1:length(sellers)
          if sellers(j).nitems > 0
              sellpos = sellpos + 1;
          end
       end
       for j=1:nbuy
          if buyers(j).money > 0
              buypos = buypos + 1;
          end
       end
    end
    
    % Introduce new items each 20 timesteps
    if mod(i, newitem) == 0
        %Change the time value in each item
%         for j=1:length(buyers)
%            for k=1:buyers(j).nitems
%               buyers(j).items(k).time = buyers(j).items(k).time + 1; 
%            end
%         end
%         for j=1:length(sellers)
%            for k=1:sellers(j).nitems
%               sellers(j).items(k).time = sellers(j).items(k).time + 1; 
%            end
%         end
        for j=1:length(sellers)
            if sellers(j).mode == 1
                sellers(j).nitems = sellers(j).nitems + round(normrnd(nitems/n_set, 0.1));
                for f=1:nbrands
                   if sellers(j).brand == f
                       for h=1:sellers(j).nitems
                           sellers(j).items(h).price = brand(f).price*brand(f).socstat/80; 
                           sellers(j).items(h).socstat = normrnd(sellers(j).socstat, 0.1);
                           sellers(j).items(h).sold = 0;
                           sellers(j).items(h).brand = sellers(j).brand;
                           sellers(j).items(h).time = i/newitem;
                       end
                   end
                end
            end
        end
    end
    
    %In every iteration old items lose social status until the have 10 social
    %status
    for j=1:length(buyers)
       for k=1:buyers(j).nitems
           buyers(j).items(k).socstat = buyers(j).items(k).socstat - rand()*5;
           buyers(j).items(k).socstat = max(buyers(j).items(k).socstat, 10);
       end
    end
    for j=1:length(sellers)
        if sellers(j).mode ~= 1
           for k=1:sellers(j).nitems
               sellers(j).items(k).socstat = sellers(j).items(k).socstat - rand()*5;
               sellers(j).items(k).socstat = max(sellers(j).items(k).socstat, 10);
           end
        end
    end
    
    %Shift the buyers & the sellers so they randomize a little bit
    
   rndb = randperm(length(buyers));
   buyers = buyers(rndb);
   rnds = randperm(length(sellers));
   sellers = sellers(rnds);
%     buyers = circshift(buyers, 100);
%     sellers = circshift(sellers, 100);
   
    nbuy = length(buyers);
    nsell = length(sellers);
%     keyboard;
    
    %Plot all the averages and shit
    figure (1);
    hold off;
    plot(iter, avg(:, 1), 'DisplayName', 'Average total selling price');
    hold on;
    drawnow;
    plot(iter, avg(:, 2), 'DisplayName', 'Socialitee average buying price');
    hold on;
    drawnow;
    plot(iter, avg(:, 3), 'DisplayName', 'Collectors average buying price');
    hold on;
    drawnow;
    plot(iter, avg(:, 4), 'DisplayName', 'Profiteers average buying price');
    hold on;
    drawnow;
    legend;

    figure(2);
    hold off;
    for j=1:size(avgt, 2)
       plot(iter, avgt(:, j), 'DisplayName', strcat('Time ', num2str(j-1)));
       hold on;
       drawnow;
    end
    legend;
    figure(3);
    hold off;
    for j=1:(size(avgb, 2))
       plot(iter, avgb(:, j), 'DisplayName', strcat('Brand', num2str(j)));
       hold on;
       drawnow;
    end
    legend;
end
figure(4);
plot(iter, avg(:, 1), 'b', 'DisplayName', 'Sell price');
hold on;
plot(iter, avg(:, 2), 'r', 'DisplayName', 'Buy price');
legend;
keyboard;
end

