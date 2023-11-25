return {
	run = function(catalogSearchParams: CatalogSearchParams, intermediateSerializedData)
		local bundleTypes = {}
		local avatarAssetTypes = {}

		for _, bundleType in catalogSearchParams.BundleType do
			table.insert(bundleTypes, bundleType.Name)
		end

		for _, avatarAssetType in catalogSearchParams.AssetTypes do
			table.insert(avatarAssetTypes, avatarAssetType.Name)
		end

		intermediateSerializedData.components = {
			catalogSearchParams.SearchKeyword,
			catalogSearchParams.MinPrice,
			catalogSearchParams.MaxPrice,
			catalogSearchParams.SortType.Name,
			catalogSearchParams.CategoryFilter.Name,
			bundleTypes,
			avatarAssetTypes,
		}
	end,
}
