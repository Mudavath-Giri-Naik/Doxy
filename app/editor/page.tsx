import { redirect } from "next/navigation";

import { EditorPageHeader } from "@/components/sections/editor-page-header";
import { MyDocumentsSection } from "@/components/sections/my-documents-section";
import { SharedDocumentsSection } from "@/components/sections/shared-documents-section";
import { StarredDocumentsSection } from "@/components/sections/starred-documents-section";
import { TrashSection } from "@/components/sections/trash-section";
import { createClient } from "@/lib/supabase/server";

type EditorPageProps = {
  searchParams: Promise<{ section?: string }>;
};

export default async function EditorPage({ searchParams }: EditorPageProps) {
  const params = await searchParams;
  const section = params.section || "all-documents";

  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/auth/login");
  }

  // Fetch documents owned by user directly to ensure they show up even if account missing
  const { data: rawDocuments, error: docsError } = await supabase
    .from("documents")
    .select("*")
    .eq("user_id", user.id)
    .order("updated_at", { ascending: false });

  if (docsError) {
    console.error("Failed to load documents:", docsError);
  }

  const documents = rawDocuments?.map((doc) => ({
    ...doc,
    user_name: user.user_metadata.name || user.email,
    user_email: user.email,
    user_picture_url: user.user_metadata.avatar_url,
  }));

  // Fetch starred documents with owner data
  const { data: starredDocuments, error: starredError } = await supabase.rpc(
    "get_starred_documents_with_users",
  );

  if (starredError) {
    console.error("Failed to load starred documents:", starredError);
  }

  // Fetch documents shared with user with owner data
  const { data: sharedDocuments, error: sharedError } = await supabase.rpc(
    "get_shared_documents_with_users",
  );

  if (sharedError) {
    console.error("Failed to load shared documents:", sharedError);
  }

  // Fetch trashed documents directly
  const { data: rawTrashedDocuments, error: trashedError } = await supabase
    .from("trashed_documents")
    .select("*")
    .eq("user_id", user.id)
    .order("trashed_at", { ascending: false });

  if (trashedError) {
    console.error("Failed to load trashed documents:", trashedError);
  }

  const trashedDocuments = rawTrashedDocuments?.map((doc) => ({
    ...doc,
    user_name: user.user_metadata.name || user.email,
    user_email: user.email,
    user_picture_url: user.user_metadata.avatar_url,
  }));

  // Determine which sections to show based on the query parameter
  const showRecent = section === "recent";
  const showStarred = section === "starred";
  const showShared = section === "shared";
  const showTrash = section === "trash";
  const showAll = section === "all-documents";

  return (
    <div className="bg-background min-h-screen">
      <EditorPageHeader user={user} />
      <div className="container mx-auto max-w-7xl space-y-12 px-4 py-8">
        {(showRecent || showAll) && (
          <MyDocumentsSection initialDocuments={documents || []} />
        )}
        {(showStarred || showAll) && (
          <StarredDocumentsSection initialDocuments={starredDocuments || []} />
        )}
        {(showShared || showAll) && (
          <SharedDocumentsSection initialDocuments={sharedDocuments || []} />
        )}
        {(showTrash || showAll) && (
          <TrashSection initialDocuments={trashedDocuments || []} />
        )}
      </div>
    </div>
  );
}
