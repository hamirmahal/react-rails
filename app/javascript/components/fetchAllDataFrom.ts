const fetchAllDataFrom = async (url: string) => {
  const operator = url.includes('?') ? '&' : '?';
  const urlToUse = url + operator;
  const allData: any[] = [];
  let page = 1;
  let thereAreMoreResults = true;
  while (thereAreMoreResults) {
    const response = await fetch(`${urlToUse}page=${page}`);
    const data = await response.json();
    allData.push(...data);
    page++;
    thereAreMoreResults = data.length > 0;
  }
  return allData;
};

export default fetchAllDataFrom;
