export interface Env {
  BUCKET: R2Bucket;
  PUBLIC_BUCKET_HOST: string;
}

// ✅ CORS HEADERS
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "*",
};

// ✅ JSON RESPONSE WITH CORS
function jsonResponse(body: unknown, init?: ResponseInit) {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: {
      "content-type": "application/json; charset=utf-8",
      ...corsHeaders,
      ...(init?.headers ?? {}),
    },
  });
}

function badRequest(message: string) {
  return jsonResponse({ error: message }, { status: 400 });
}

function methodNotAllowed() {
  return jsonResponse({ error: "Method Not Allowed" }, { status: 405 });
}

// ✅ SLUG GENERATION
function slugify(input: string) {
  return input
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)+/g, "")
    .slice(0, 80);
}

// ✅ FILE EXTENSION DETECTION
function fileExtensionFrom(file: File) {
  const byType = (file.type || "").toLowerCase();
  if (byType === "image/jpeg" || byType === "image/jpg") return "jpg";
  if (byType === "image/png") return "png";
  if (byType === "image/webp") return "webp";
  if (byType === "image/gif") return "gif";

  const name = (file.name || "").trim();
  const dot = name.lastIndexOf(".");
  if (dot > -1 && dot < name.length - 1) {
    const ext = name.slice(dot + 1).toLowerCase();
    if (/^[a-z0-9]{1,8}$/.test(ext)) return ext;
  }
  return "bin";
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // ❌ Wrong route
    if (url.pathname !== "/upload-to-r2") {
      return new Response("Not Found", { status: 404, headers: corsHeaders });
    }

    // ✅ CORS PREFLIGHT
    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: corsHeaders,
      });
    }

    // ❌ Only POST allowed
    if (request.method !== "POST") {
      return methodNotAllowed();
    }

    // ❌ Validate content-type
    const contentType = request.headers.get("content-type") || "";
    if (!contentType.toLowerCase().includes("multipart/form-data")) {
      return badRequest("Expected multipart/form-data");
    }

    // ✅ Parse form data
    let form: FormData;
    try {
      form = await request.formData();
    } catch {
      return badRequest("Invalid multipart/form-data");
    }

    // ✅ Get propertyName
    const propertyName = (form.get("propertyName") || "").toString();
    if (!propertyName.trim()) {
      return badRequest("propertyName is required");
    }

    const folder = slugify(propertyName);
    if (!folder) {
      return badRequest("propertyName is invalid");
    }

    // ✅ Get files
    const imageEntries = form.getAll("images");
    const files: File[] = imageEntries.filter((v): v is File => v instanceof File);

    if (files.length === 0) {
      return badRequest("No images provided");
    }

    if (!env.PUBLIC_BUCKET_HOST || !env.PUBLIC_BUCKET_HOST.trim()) {
      return jsonResponse(
        { error: "PUBLIC_BUCKET_HOST is not configured" },
        { status: 500 }
      );
    }

    const urls: string[] = [];

    // ✅ Upload each file
    for (let index = 0; index < files.length; index++) {
      const file = files[index];

      if (!file.type || !file.type.toLowerCase().startsWith("image/")) {
        return badRequest("Only image uploads are supported");
      }

      const uuid = crypto.randomUUID();
      const ext = fileExtensionFrom(file);
      const key = `${folder}/${uuid}-${index}.${ext}`;

      await env.BUCKET.put(key, file.stream(), {
        httpMetadata: {
          contentType: file.type,
        },
      });

      const publicHost = env.PUBLIC_BUCKET_HOST
        .trim()
        .replace(/^https?:\/\//i, "");

      const publicUrl = `https://${publicHost}/${key}`;
      urls.push(publicUrl);
    }

    // ✅ FINAL RESPONSE
    return jsonResponse({ urls });
  },
};