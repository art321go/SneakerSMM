function [] = Financial_Model(n_agents)

agent = struct ('prob_prof', 0, 'prob_coll', 0, 'prob_set', 0, 'prob_soc', 0, 'money', 0, 'soc_stat', 0);
people = repmat(agent, 1, n_agents);
total = 0;
n_soc = 0; n_prof = 0; n_coll = 0; n_set = 0;

while(n_soc<=0 || n_prof<=0 || n_coll<=0 || n_set<=0)
n_set = randi(round(n_agents*0.1));
n_soc = randi([round(n_agents*0.25), round(n_agents*0.6)]);
n_prof = randi([round(n_agents*0.2), round(n_agents*0.5)]);
n_coll = n_agents - n_prof - n_soc - n_set;
end

for i=1:n_agents %Initialize people fields
   prob = rand(4, 1);
   for j=1:4
      total = total + prob(j);
   end
   people(i).prob_prof = prob(1)/total;
   people(i).prob_coll = prob(2)/total;
   people(i).prob_set = prob(3)/total;
   people(i).prob_soc = prob(4)/total;
   total = 0;
end
keyboard;

end

