import Hakyll

main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route idRoute
        compile compressCssCompiler

    -- match (fromList ["about.rst", "contact.markdown"]) $ do
    --     route $ setExtension "html"
    --     compile $
    --         pandocCompiler
    --             >>= loadAndApplyTemplate "templates/default.html" defaultContext
    --             >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $
            pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html" postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts)
                        `mappend` constField "title" "Archives"
                        `mappend` defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts)
                        `mappend` constField "title" "Bartek's website"
                        `mappend` defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

-- updatedContext :: Item a -> Compiler String
-- updatedContext item = do
--     filePath <- getResourceFilePath
--     date <- recompilingUnsafeCompiler $ lastUpdated filePath
--     when (date == "")
--     return undefined
--   where
--     lastUpdated :: FilePath -> IO String
--     lastUpdated filePath =
--         readProcess
--             "git"
--             ["log", "-1", "--format='%ad'", "--date=short", "--", filePath]
--             ""

postCtx :: Context String
postCtx =
    let format = "%-d %B %Y"
     in dateField "date" format
            `mappend` modificationTimeField "updated" format
            `mappend` defaultContext
