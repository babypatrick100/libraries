return {
	run = function(serializedCatalogSearchParams)
		local components = serializedCatalogSearchParams.components
		local bundleTypes = {}
		local avatarAssetTypes = {}

		for _, bundleTypeName in components[5] do
			table.insert(bundleTypes, Enum.BundleType[bundleTypeName])
		end

		for _, assetTypeName in components[6] do
			table.insert(avatarAssetTypes, Enum.AssetType[assetTypeName])
		end

		local catalogSearchParams = CatalogSearchParams.new()
		catalogSearchParams.SearchKeyword = components[1]
		catalogSearchParams.MinPrice = components[2]
		catalogSearchParams.MaxPrice = components[3]
		catalogSearchParams.SortType = Enum.CatalogSortType[components[4]]
		catalogSearchParams.CategoryFilter = Enum.CatalogCategoryFilter[components[5]]
		catalogSearchParams.BundleType = bundleTypes
		catalogSearchParams.AssetTypes = avatarAssetTypes
		return catalogSearchParams
	end,
}
