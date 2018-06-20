x = cell2mat(out);

[G, ID] = findgroups(x(:,1));

media_grupos = splitapply(@mean,x(:,2),G);


xs = [0, 5000];
ys = [89588 89588];

createfigure(x(:,1), x(:,2), ID, media_grupos, xs, ys);

