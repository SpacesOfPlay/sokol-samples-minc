// spine_c


private {
    bool isnan(f32 x) { return x != x; }
    bool isnan(f64 x) { return x != x; }
}

// transminc: C stdlib constants referenced by source
const i32 INT_MAX = 2147483647;
const i32 INT_MIN = cast(i32, 0 - 2147483647 - 1);
const i32 SEEK_SET = 0;
const i32 SEEK_END = 2;

// transminc: C #define values surfaced as compile-time configuration
@define "SPINE_JSON_HAVE_PREV" 0
@define "SPINE_JSON_DEBUG" 0

enum spAttachmentType {
    SP_ATTACHMENT_REGION = 0,
    SP_ATTACHMENT_BOUNDING_BOX = 1,
    SP_ATTACHMENT_MESH = 2,
    SP_ATTACHMENT_LINKED_MESH = 3,
    SP_ATTACHMENT_PATH = 4,
    SP_ATTACHMENT_POINT = 5,
    SP_ATTACHMENT_CLIPPING = 6,
}

enum spInherit {
    SP_INHERIT_NORMAL = 0,
    SP_INHERIT_ONLYTRANSLATION = 1,
    SP_INHERIT_NOROTATIONORREFLECTION = 2,
    SP_INHERIT_NOSCALE = 3,
    SP_INHERIT_NOSCALEORREFLECTION = 4,
}

/******************************************************************************
 * Spine Runtimes License Agreement
 * Last updated July 28, 2023. Replaces all prior versions.
 *
 * Copyright (c) 2013-2023, Esoteric Software LLC
 *
 * Integration of the Spine Runtimes into software or otherwise creating
 * derivative works of the Spine Runtimes is permitted under the terms and
 * conditions of Section 2 of the Spine Editor License Agreement:
 * http://esotericsoftware.com/spine-editor-license
 *
 * Otherwise, it is permitted to integrate the Spine Runtimes into software or
 * otherwise create derivative works of the Spine Runtimes (collectively,
 * "Products"), provided that each user of the Products must obtain their own
 * Spine Editor license and redistribution of the Products in any form must
 * include this license and copyright notice.
 *
 * THE SPINE RUNTIMES ARE PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
 * BUSINESS INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THE
 * SPINE RUNTIMES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/
/** Determines how physics and other non-deterministic updates are applied. */
enum spPhysics {
    SP_PHYSICS_NONE = 0,
    SP_PHYSICS_RESET = 1,
    SP_PHYSICS_UPDATE = 2,
    SP_PHYSICS_POSE = 3,
}

enum spBlendMode {
    SP_BLEND_MODE_NORMAL = 0,
    SP_BLEND_MODE_ADDITIVE = 1,
    SP_BLEND_MODE_MULTIPLY = 2,
    SP_BLEND_MODE_SCREEN = 3,
}

enum spAtlasFormat {
    SP_ATLAS_UNKNOWN_FORMAT = 0,
    SP_ATLAS_ALPHA = 1,
    SP_ATLAS_INTENSITY = 2,
    SP_ATLAS_LUMINANCE_ALPHA = 3,
    SP_ATLAS_RGB565 = 4,
    SP_ATLAS_RGBA4444 = 5,
    SP_ATLAS_RGB888 = 6,
    SP_ATLAS_RGBA8888 = 7,
}

enum spAtlasFilter {
    SP_ATLAS_UNKNOWN_FILTER = 0,
    SP_ATLAS_NEAREST = 1,
    SP_ATLAS_LINEAR = 2,
    SP_ATLAS_MIPMAP = 3,
    SP_ATLAS_MIPMAP_NEAREST_NEAREST = 4,
    SP_ATLAS_MIPMAP_LINEAR_NEAREST = 5,
    SP_ATLAS_MIPMAP_NEAREST_LINEAR = 6,
    SP_ATLAS_MIPMAP_LINEAR_LINEAR = 7,
}

enum spAtlasWrap {
    SP_ATLAS_MIRROREDREPEAT = 0,
    SP_ATLAS_CLAMPTOEDGE = 1,
    SP_ATLAS_REPEAT = 2,
}

enum spMixBlend {
    SP_MIX_BLEND_SETUP = 0,
    SP_MIX_BLEND_FIRST = 1,
    SP_MIX_BLEND_REPLACE = 2,
    SP_MIX_BLEND_ADD = 3,
}

enum spMixDirection {
    SP_MIX_DIRECTION_IN = 0,
    SP_MIX_DIRECTION_OUT = 1,
}

/**/
enum spTimelineType {
    SP_TIMELINE_ATTACHMENT = 0,
    SP_TIMELINE_ALPHA = 1,
    SP_TIMELINE_PATHCONSTRAINTPOSITION = 2,
    SP_TIMELINE_PATHCONSTRAINTSPACING = 3,
    SP_TIMELINE_ROTATE = 4,
    SP_TIMELINE_SCALEX = 5,
    SP_TIMELINE_SCALEY = 6,
    SP_TIMELINE_SHEARX = 7,
    SP_TIMELINE_SHEARY = 8,
    SP_TIMELINE_TRANSLATEX = 9,
    SP_TIMELINE_TRANSLATEY = 10,
    SP_TIMELINE_SCALE = 11,
    SP_TIMELINE_SHEAR = 12,
    SP_TIMELINE_TRANSLATE = 13,
    SP_TIMELINE_DEFORM = 14,
    SP_TIMELINE_SEQUENCE = 15,
    SP_TIMELINE_INHERIT = 16,
    SP_TIMELINE_IKCONSTRAINT = 17,
    SP_TIMELINE_PATHCONSTRAINTMIX = 18,
    SP_TIMELINE_PHYSICSCONSTRAINT_INERTIA = 19,
    SP_TIMELINE_PHYSICSCONSTRAINT_STRENGTH = 20,
    SP_TIMELINE_PHYSICSCONSTRAINT_DAMPING = 21,
    SP_TIMELINE_PHYSICSCONSTRAINT_MASS = 22,
    SP_TIMELINE_PHYSICSCONSTRAINT_WIND = 23,
    SP_TIMELINE_PHYSICSCONSTRAINT_GRAVITY = 24,
    SP_TIMELINE_PHYSICSCONSTRAINT_MIX = 25,
    SP_TIMELINE_PHYSICSCONSTRAINT_RESET = 26,
    SP_TIMELINE_RGB2 = 27,
    SP_TIMELINE_RGBA2 = 28,
    SP_TIMELINE_RGBA = 29,
    SP_TIMELINE_RGB = 30,
    SP_TIMELINE_TRANSFORMCONSTRAINT = 31,
    SP_TIMELINE_DRAWORDER = 32,
    SP_TIMELINE_EVENT = 33,
}

/**/
enum spProperty {
    SP_PROPERTY_ROTATE = 1,
    SP_PROPERTY_X = 2,
    SP_PROPERTY_Y = 4,
    SP_PROPERTY_SCALEX = 8,
    SP_PROPERTY_SCALEY = 16,
    SP_PROPERTY_SHEARX = 32,
    SP_PROPERTY_SHEARY = 64,
    SP_PROPERTY_INHERIT = 128,
    SP_PROPERTY_RGB = 256,
    SP_PROPERTY_ALPHA = 512,
    SP_PROPERTY_RGB2 = 1024,
    SP_PROPERTY_ATTACHMENT = 2048,
    SP_PROPERTY_DEFORM = 4096,
    SP_PROPERTY_EVENT = 8192,
    SP_PROPERTY_DRAWORDER = 16384,
    SP_PROPERTY_IKCONSTRAINT = 32768,
    SP_PROPERTY_TRANSFORMCONSTRAINT = 65536,
    SP_PROPERTY_PATHCONSTRAINT_POSITION = 131072,
    SP_PROPERTY_PATHCONSTRAINT_SPACING = 262144,
    SP_PROPERTY_PATHCONSTRAINT_MIX = 524288,
    SP_PROPERTY_PHYSICSCONSTRAINT_INERTIA = 1048576,
    SP_PROPERTY_PHYSICSCONSTRAINT_STRENGTH = 2097152,
    SP_PROPERTY_PHYSICSCONSTRAINT_DAMPING = 4194304,
    SP_PROPERTY_PHYSICSCONSTRAINT_MASS = 8388608,
    SP_PROPERTY_PHYSICSCONSTRAINT_WIND = 16777216,
    SP_PROPERTY_PHYSICSCONSTRAINT_GRAVITY = 33554432,
    SP_PROPERTY_PHYSICSCONSTRAINT_MIX = 67108864,
    SP_PROPERTY_PHYSICSCONSTRAINT_RESET = 134217728,
    SP_PROPERTY_SEQUENCE = 268435456,
}

enum spPositionMode {
    SP_POSITION_MODE_FIXED = 0,
    SP_POSITION_MODE_PERCENT = 1,
}

enum spSpacingMode {
    SP_SPACING_MODE_LENGTH = 0,
    SP_SPACING_MODE_FIXED = 1,
    SP_SPACING_MODE_PERCENT = 2,
    SP_SPACING_MODE_PROPORTIONAL = 3,
}

enum spRotateMode {
    SP_ROTATE_MODE_TANGENT = 0,
    SP_ROTATE_MODE_CHAIN = 1,
    SP_ROTATE_MODE_CHAIN_SCALE = 2,
}

enum spEventType {
    SP_ANIMATION_START = 0,
    SP_ANIMATION_INTERRUPT = 1,
    SP_ANIMATION_END = 2,
    SP_ANIMATION_COMPLETE = 3,
    SP_ANIMATION_DISPOSE = 4,
    SP_ANIMATION_EVENT = 5,
}

enum spVertexIndex {
    BLX = 0,
    BLY = 1,
    ULX = 2,
    ULY = 3,
    URX = 4,
    URY = 5,
    BRX = 6,
    BRY = 7,
}

enum _spUpdateType {
    SP_UPDATE_BONE = 0,
    SP_UPDATE_IK_CONSTRAINT = 1,
    SP_UPDATE_PATH_CONSTRAINT = 2,
    SP_UPDATE_TRANSFORM_CONSTRAINT = 3,
    SP_UPDATE_PHYSICS_CONSTRAINT = 4,
}

type spPropertyId = u64;
type spCurveTimeline1 = spCurveTimeline;
type spCurveTimeline2 = spCurveTimeline;
type spSkinEntry = _Entry;
type spAnimationStateListener = fn(spAnimationState*, spEventType, spTrackEntry*, spEvent*): void;
struct _finddata_t {
    u32 attrib;
    u32 _pad0;
    i64 time_create;
    i64 time_access;
    i64 time_write;
    u32 size;
    u8[260] name;
}

struct spEventData {
    u8* name;
    i32 intValue;
    f32 floatValue;
    u8* stringValue;
    u8* audioPath;
    f32 volume;
    f32 balance;
}

struct spEvent {
    spEventData* data;
    f32 time;
    i32 intValue;
    f32 floatValue;
    u8* stringValue;
    f32 volume;
    f32 balance;
}

struct spAttachment {
    u8* name;
    spAttachmentType type;
    void* vtable;
    i32 refCount;
    spAttachmentLoader* attachmentLoader;
}

struct spColor {
    f32 r;
    f32 g;
    f32 b;
    f32 a;
}

struct spBoneData {
    i32 index;
    u8* name;
    spBoneData* parent;
    f32 length;
    f32 x;
    f32 y;
    f32 rotation;
    f32 scaleX;
    f32 scaleY;
    f32 shearX;
    f32 shearY;
    spInherit inherit;
    i32 skinRequired;
    spColor color;
    u8* icon;
    i32 visible;
}

struct spBone {
    spBoneData* data;
    spSkeleton* skeleton;
    spBone* parent;
    i32 childrenCount;
    spBone** children;
    f32 x;
    f32 y;
    f32 rotation;
    f32 scaleX;
    f32 scaleY;
    f32 shearX;
    f32 shearY;
    f32 ax;
    f32 ay;
    f32 arotation;
    f32 ascaleX;
    f32 ascaleY;
    f32 ashearX;
    f32 ashearY;
    f32 a;
    f32 b;
    f32 worldX;
    f32 c;
    f32 d;
    f32 worldY;
    i32 sorted;
    i32 active;
    spInherit inherit;
}

struct spSlotData {
    i32 index;
    u8* name;
    spBoneData* boneData;
    u8* attachmentName;
    spColor color;
    spColor* darkColor;
    spBlendMode blendMode;
    i32 visible;
}

struct spSlot {
    spSlotData* data;
    spBone* bone;
    spColor color;
    spColor* darkColor;
    spAttachment* attachment;
    i32 attachmentState;
    i32 deformCapacity;
    i32 deformCount;
    f32* deform;
    i32 sequenceIndex;
}

struct spVertexAttachment {
    spAttachment super;
    i32 bonesCount;
    i32* bones;
    i32 verticesCount;
    f32* vertices;
    i32 worldVerticesLength;
    spAttachment* timelineAttachment;
    i32 id;
}

/******************************************************************************
 * Spine Runtimes License Agreement
 * Last updated July 28, 2023. Replaces all prior versions.
 *
 * Copyright (c) 2013-2023, Esoteric Software LLC
 *
 * Integration of the Spine Runtimes into software or otherwise creating
 * derivative works of the Spine Runtimes is permitted under the terms and
 * conditions of Section 2 of the Spine Editor License Agreement:
 * http://esotericsoftware.com/spine-editor-license
 *
 * Otherwise, it is permitted to integrate the Spine Runtimes into software or
 * otherwise create derivative works of the Spine Runtimes (collectively,
 * "Products"), provided that each user of the Products must obtain their own
 * Spine Editor license and redistribution of the Products in any form must
 * include this license and copyright notice.
 *
 * THE SPINE RUNTIMES ARE PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
 * BUSINESS INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THE
 * SPINE RUNTIMES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/
struct spTextureRegion {
    void* rendererObject;
    f32 u;
    f32 v;
    f32 u2;
    f32 v2;
    i32 degrees;
    f32 offsetX;
    f32 offsetY;
    i32 width;
    i32 height;
    i32 originalWidth;
    i32 originalHeight;
}

struct spFloatArray {
    i32 size;
    i32 capacity;
    f32* items;
}

struct spIntArray {
    i32 size;
    i32 capacity;
    i32* items;
}

struct spShortArray {
    i32 size;
    i32 capacity;
    i16* items;
}

struct spUnsignedShortArray {
    i32 size;
    i32 capacity;
    u16* items;
}

struct spArrayFloatArray {
    i32 size;
    i32 capacity;
    spFloatArray** items;
}

struct spArrayShortArray {
    i32 size;
    i32 capacity;
    spShortArray** items;
}

struct spAtlasPage {
    spAtlas* atlas;
    u8* name;
    spAtlasFormat format;
    spAtlasFilter minFilter;
    spAtlasFilter magFilter;
    spAtlasWrap uWrap;
    spAtlasWrap vWrap;
    void* rendererObject;
    i32 width;
    i32 height;
    i32 pma;
    spAtlasPage* next;
}

/**/
struct spKeyValue {
    u8* name;
    f32[5] values;
}

struct spKeyValueArray {
    i32 size;
    i32 capacity;
    spKeyValue* items;
}

struct spAtlasRegion {
    spTextureRegion super;
    u8* name;
    i32 x;
    i32 y;
    i32 index;
    i32* splits;
    i32* pads;
    spKeyValueArray* keyValues;
    spAtlasPage* page;
    spAtlasRegion* next;
}

/**/
struct spAtlas {
    spAtlasPage* pages;
    spAtlasRegion* regions;
    void* rendererObject;
}

struct spTextureRegionArray {
    i32 size;
    i32 capacity;
    spTextureRegion** items;
}

struct spSequence {
    i32 id;
    i32 start;
    i32 digits;
    i32 setupIndex;
    spTextureRegionArray* regions;
}

struct spPropertyIdArray {
    i32 size;
    i32 capacity;
    spPropertyId* items;
}

struct spTimelineArray {
    i32 size;
    i32 capacity;
    spTimeline** items;
}

struct spAnimation {
    u8* name;
    f32 duration;
    spTimelineArray* timelines;
    spPropertyIdArray* timelineIds;
}

struct _spTimelineVtable {
    fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void apply;
    fn(spTimeline*): void dispose;
    fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void setBezier;
}

struct spTimeline {
    _spTimelineVtable vtable;
    spPropertyId[3] propertyIds;
    i32 propertyIdsCount;
    spFloatArray* frames;
    i32 frameCount;
    i32 frameEntries;
    spTimelineType type;
}

/**/
struct spCurveTimeline {
    spTimeline super;
    spFloatArray* curves;
}

/**/
struct spRotateTimeline {
    spCurveTimeline1 super;
    i32 boneIndex;
}

/**/
struct spTranslateTimeline {
    spCurveTimeline2 super;
    i32 boneIndex;
}

/**/
struct spTranslateXTimeline {
    spCurveTimeline1 super;
    i32 boneIndex;
}

/**/
struct spTranslateYTimeline {
    spCurveTimeline1 super;
    i32 boneIndex;
}

/**/
struct spScaleTimeline {
    spCurveTimeline2 super;
    i32 boneIndex;
}

/**/
struct spScaleXTimeline {
    spCurveTimeline1 super;
    i32 boneIndex;
}

/**/
struct spScaleYTimeline {
    spCurveTimeline1 super;
    i32 boneIndex;
}

/**/
struct spShearTimeline {
    spCurveTimeline2 super;
    i32 boneIndex;
}

/**/
struct spShearXTimeline {
    spCurveTimeline1 super;
    i32 boneIndex;
}

/**/
struct spShearYTimeline {
    spCurveTimeline1 super;
    i32 boneIndex;
}

/**/
struct spRGBATimeline {
    spCurveTimeline2 super;
    i32 slotIndex;
}

/**/
struct spRGBTimeline {
    spCurveTimeline2 super;
    i32 slotIndex;
}

/**/
struct spAlphaTimeline {
    spCurveTimeline1 super;
    i32 slotIndex;
}

/**/
struct spRGBA2Timeline {
    spCurveTimeline super;
    i32 slotIndex;
}

/**/
struct spRGB2Timeline {
    spCurveTimeline super;
    i32 slotIndex;
}

/**/
struct spAttachmentTimeline {
    spTimeline super;
    i32 slotIndex;
    u8** attachmentNames;
}

/**/
struct spDeformTimeline {
    spCurveTimeline super;
    i32 frameVerticesCount;
    f32** frameVertices;
    i32 slotIndex;
    spAttachment* attachment;
}

/**/
struct spSequenceTimeline {
    spTimeline super;
    i32 slotIndex;
    spAttachment* attachment;
}

/**/
/**/
struct spEventTimeline {
    spTimeline super;
    spEvent** events;
}

/**/
struct spDrawOrderTimeline {
    spTimeline super;
    i32** drawOrders;
    i32 slotsCount;
}

/**/
struct spInheritTimeline {
    spTimeline super;
    i32 boneIndex;
}

/**/
struct spIkConstraintTimeline {
    spCurveTimeline super;
    i32 ikConstraintIndex;
}

/**/
struct spTransformConstraintTimeline {
    spCurveTimeline super;
    i32 transformConstraintIndex;
}

/**/
struct spPathConstraintPositionTimeline {
    spCurveTimeline super;
    i32 pathConstraintIndex;
}

/**/
struct spPathConstraintSpacingTimeline {
    spCurveTimeline super;
    i32 pathConstraintIndex;
}

/**/
struct spPathConstraintMixTimeline {
    spCurveTimeline super;
    i32 pathConstraintIndex;
}

/**/
struct spPhysicsConstraintTimeline {
    spCurveTimeline super;
    i32 physicsConstraintIndex;
}

/**/
struct spPhysicsConstraintResetTimeline {
    spTimeline super;
    i32 physicsConstraintIndex;
}

struct spIkConstraintData {
    u8* name;
    i32 order;
    i32 skinRequired;
    i32 bonesCount;
    spBoneData** bones;
    spBoneData* target;
    i32 bendDirection;
    i32 compress;
    i32 stretch;
    i32 uniform;
    f32 mix;
    f32 softness;
}

struct spIkConstraint {
    spIkConstraintData* data;
    i32 bonesCount;
    spBone** bones;
    spBone* target;
    i32 bendDirection;
    i32 compress;
    i32 stretch;
    f32 mix;
    f32 softness;
    i32 active;
}

struct spTransformConstraintData {
    u8* name;
    i32 order;
    i32 skinRequired;
    i32 bonesCount;
    spBoneData** bones;
    spBoneData* target;
    f32 mixRotate;
    f32 mixX;
    f32 mixY;
    f32 mixScaleX;
    f32 mixScaleY;
    f32 mixShearY;
    f32 offsetRotation;
    f32 offsetX;
    f32 offsetY;
    f32 offsetScaleX;
    f32 offsetScaleY;
    f32 offsetShearY;
    i32 relative;
    i32 local;
}

struct spPathConstraintData {
    u8* name;
    i32 order;
    i32 skinRequired;
    i32 bonesCount;
    spBoneData** bones;
    spSlotData* target;
    spPositionMode positionMode;
    spSpacingMode spacingMode;
    spRotateMode rotateMode;
    f32 offsetRotation;
    f32 position;
    f32 spacing;
    f32 mixRotate;
    f32 mixX;
    f32 mixY;
}

struct spPhysicsConstraintData {
    u8* name;
    i32 order;
    i32 skinRequired;
    spBoneData* bone;
    f32 x;
    f32 y;
    f32 rotate;
    f32 scaleX;
    f32 shearX;
    f32 limit;
    f32 step;
    f32 inertia;
    f32 strength;
    f32 damping;
    f32 massInverse;
    f32 wind;
    f32 gravity;
    f32 mix;
    i32 inertiaGlobal;
    i32 strengthGlobal;
    i32 dampingGlobal;
    i32 massGlobal;
    i32 windGlobal;
    i32 gravityGlobal;
    i32 mixGlobal;
}

struct spBoneDataArray {
    i32 size;
    i32 capacity;
    spBoneData** items;
}

struct spIkConstraintDataArray {
    i32 size;
    i32 capacity;
    spIkConstraintData** items;
}

struct spTransformConstraintDataArray {
    i32 size;
    i32 capacity;
    spTransformConstraintData** items;
}

struct spPathConstraintDataArray {
    i32 size;
    i32 capacity;
    spPathConstraintData** items;
}

struct spPhysicsConstraintDataArray {
    i32 size;
    i32 capacity;
    spPhysicsConstraintData** items;
}

struct spSkin {
    u8* name;
    spBoneDataArray* bones;
    spIkConstraintDataArray* ikConstraints;
    spTransformConstraintDataArray* transformConstraints;
    spPathConstraintDataArray* pathConstraints;
    spPhysicsConstraintDataArray* physicsConstraints;
    spColor color;
}

struct _Entry {
    i32 slotIndex;
    u8* name;
    spAttachment* attachment;
    _Entry* next;
}

struct _SkinHashTableEntry {
    _Entry* entry;
    _SkinHashTableEntry* next;
}

struct _spSkin {
    spSkin super;
    _Entry* entries;
    _SkinHashTableEntry*[100] entriesHashTable;
}

struct spSkeletonData {
    u8* version;
    u8* hash;
    f32 x;
    f32 y;
    f32 width;
    f32 height;
    f32 referenceScale;
    f32 fps;
    u8* imagesPath;
    u8* audioPath;
    i32 stringsCount;
    u8** strings;
    i32 bonesCount;
    spBoneData** bones;
    i32 slotsCount;
    spSlotData** slots;
    i32 skinsCount;
    spSkin** skins;
    spSkin* defaultSkin;
    i32 eventsCount;
    spEventData** events;
    i32 animationsCount;
    spAnimation** animations;
    i32 ikConstraintsCount;
    spIkConstraintData** ikConstraints;
    i32 transformConstraintsCount;
    spTransformConstraintData** transformConstraints;
    i32 pathConstraintsCount;
    spPathConstraintData** pathConstraints;
    i32 physicsConstraintsCount;
    spPhysicsConstraintData** physicsConstraints;
}

struct spTransformConstraint {
    spTransformConstraintData* data;
    i32 bonesCount;
    spBone** bones;
    spBone* target;
    f32 mixRotate;
    f32 mixX;
    f32 mixY;
    f32 mixScaleX;
    f32 mixScaleY;
    f32 mixShearY;
    i32 active;
}

struct spPathAttachment {
    spVertexAttachment super;
    i32 lengthsLength;
    f32* lengths;
    i32 closed;
    i32 constantSpeed;
    spColor color;
}

struct spPathConstraint {
    spPathConstraintData* data;
    i32 bonesCount;
    spBone** bones;
    spSlot* target;
    f32 position;
    f32 spacing;
    f32 mixRotate;
    f32 mixX;
    f32 mixY;
    i32 spacesCount;
    f32* spaces;
    i32 positionsCount;
    f32* positions;
    i32 worldCount;
    f32* world;
    i32 curvesCount;
    f32* curves;
    i32 lengthsCount;
    f32* lengths;
    f32[10] segments;
    i32 active;
}

struct spPhysicsConstraint {
    spPhysicsConstraintData* data;
    spBone* bone;
    f32 inertia;
    f32 strength;
    f32 damping;
    f32 massInverse;
    f32 wind;
    f32 gravity;
    f32 mix;
    i32 reset;
    f32 ux;
    f32 uy;
    f32 cx;
    f32 cy;
    f32 tx;
    f32 ty;
    f32 xOffset;
    f32 xVelocity;
    f32 yOffset;
    f32 yVelocity;
    f32 rotateOffset;
    f32 rotateVelocity;
    f32 scaleOffset;
    f32 scaleVelocity;
    i32 active;
    spSkeleton* skeleton;
    f32 remaining;
    f32 lastTime;
}

struct spSkeleton {
    spSkeletonData* data;
    i32 bonesCount;
    spBone** bones;
    spBone* root;
    i32 slotsCount;
    spSlot** slots;
    spSlot** drawOrder;
    i32 ikConstraintsCount;
    spIkConstraint** ikConstraints;
    i32 transformConstraintsCount;
    spTransformConstraint** transformConstraints;
    i32 pathConstraintsCount;
    spPathConstraint** pathConstraints;
    i32 physicsConstraintsCount;
    spPhysicsConstraint** physicsConstraints;
    spSkin* skin;
    spColor color;
    f32 scaleX;
    f32 scaleY;
    f32 x;
    f32 y;
    f32 time;
}

struct spAttachmentLoader {
    u8* error1;
    u8* error2;
    void* vtable;
}

struct spRegionAttachment {
    spAttachment super;
    u8* path;
    f32 x;
    f32 y;
    f32 scaleX;
    f32 scaleY;
    f32 rotation;
    f32 width;
    f32 height;
    spColor color;
    void* rendererObject;
    spTextureRegion* region;
    spSequence* sequence;
    f32[8] offset;
    f32[8] uvs;
}

struct spMeshAttachment {
    spVertexAttachment super;
    void* rendererObject;
    spTextureRegion* region;
    spSequence* sequence;
    u8* path;
    f32* regionUVs;
    f32* uvs;
    i32 trianglesCount;
    u16* triangles;
    spColor color;
    i32 hullLength;
    spMeshAttachment* parentMesh;
    i32 edgesCount;
    u16* edges;
    f32 width;
    f32 height;
}

struct spBoundingBoxAttachment {
    spVertexAttachment super;
    spColor color;
}

struct spClippingAttachment {
    spVertexAttachment super;
    spSlotData* endSlot;
    spColor color;
}

struct spPointAttachment {
    spAttachment super;
    f32 x;
    f32 y;
    f32 rotation;
    spColor color;
}

struct spAnimationStateData {
    spSkeletonData* skeletonData;
    f32 defaultMix;
    void* entries;
}

struct spTrackEntryArray {
    i32 size;
    i32 capacity;
    spTrackEntry** items;
}

struct spTrackEntry {
    spAnimation* animation;
    spTrackEntry* previous;
    spTrackEntry* next;
    spTrackEntry* mixingFrom;
    spTrackEntry* mixingTo;
    spAnimationStateListener listener;
    i32 trackIndex;
    i32 loop;
    i32 holdPrevious;
    i32 reverse;
    i32 shortestRotation;
    f32 eventThreshold;
    f32 mixAttachmentThreshold;
    f32 alphaAttachmentThreshold;
    f32 mixDrawOrderThreshold;
    f32 animationStart;
    f32 animationEnd;
    f32 animationLast;
    f32 nextAnimationLast;
    f32 delay;
    f32 trackTime;
    f32 trackLast;
    f32 nextTrackLast;
    f32 trackEnd;
    f32 timeScale;
    f32 alpha;
    f32 mixTime;
    f32 mixDuration;
    f32 interruptAlpha;
    f32 totalAlpha;
    spMixBlend mixBlend;
    spIntArray* timelineMode;
    spTrackEntryArray* timelineHoldMix;
    f32* timelinesRotation;
    i32 timelinesRotationCount;
    void* rendererObject;
    void* userData;
}

struct spAnimationState {
    spAnimationStateData* data;
    i32 tracksCount;
    spTrackEntry** tracks;
    spAnimationStateListener listener;
    f32 timeScale;
    void* rendererObject;
    void* userData;
    i32 unkeyedState;
}

/**/
unsafe_union _spEventQueueItem {
    i32 type;
    spTrackEntry* entry;
    spEvent* event;
}

struct _spEventQueue {
    _spAnimationState* state;
    _spEventQueueItem* objects;
    i32 objectsCount;
    i32 objectsCapacity;
    i32 drainDisabled;
}

struct _spAnimationState {
    spAnimationState super;
    i32 eventsCount;
    spEvent** events;
    _spEventQueue* queue;
    spPropertyId* propertyIDs;
    i32 propertyIDsCount;
    i32 propertyIDsCapacity;
    i32 animationsChanged;
}

struct _ToEntry {
    spAnimation* animation;
    f32 duration;
    _ToEntry* next;
}

struct _FromEntry {
    spAnimation* animation;
    _ToEntry* toEntries;
    _FromEntry* next;
}

/**/
struct SimpleString {
    u8* start;
    u8* end;
    i32 length;
}

struct AtlasInput {
    u8* start;
    u8* end;
    u8* index;
    i32 length;
    SimpleString line;
}

struct spAtlasAttachmentLoader {
    spAttachmentLoader super;
    spAtlas* atlas;
}

struct _spAttachmentVtable {
    fn(spAttachment*): void dispose;
    fn(spAttachment*): spAttachment* copy;
}

struct _spAttachmentLoaderVtable {
    fn(spAttachmentLoader*, spSkin*, spAttachmentType, u8*, u8*, spSequence*): spAttachment* createAttachment;
    fn(spAttachmentLoader*, spAttachment*): void configureAttachment;
    fn(spAttachmentLoader*, spAttachment*): void disposeAttachment;
    fn(spAttachmentLoader*): void dispose;
}

/* The Json structure: */
struct Json {
    Json* next;
    Json* child;
    i32 type;
    i32 size;
    u8* valueString;
    i32 valueInt;
    f32 valueFloat;
    u8* name;
}

struct _spUpdate {
    _spUpdateType type;
    void* object;
}

struct _spSkeleton {
    spSkeleton super;
    i32 updateCacheCount;
    i32 updateCacheCapacity;
    _spUpdate* updateCache;
}

struct spSkeletonBinary {
    f32 scale;
    spAttachmentLoader* attachmentLoader;
    u8* error;
}

struct _dataInput {
    u8* cursor;
    u8* end;
}

struct _spLinkedMeshBinary {
    u8* parent;
    i32 skinIndex;
    i32 slotIndex;
    spMeshAttachment* mesh;
    i32 inheritTimeline;
}

struct _spSkeletonBinary {
    spSkeletonBinary super;
    i32 ownsLoader;
    i32 linkedMeshCount;
    i32 linkedMeshCapacity;
    _spLinkedMeshBinary* linkedMeshes;
}

private unsafe_union intToFloat_t {
    i32 intValue;
    f32 floatValue;
}

struct spPolygon {
    f32* vertices;
    i32 count;
    i32 capacity;
}

/**/
struct spSkeletonBounds {
    i32 count;
    spBoundingBoxAttachment** boundingBoxes;
    spPolygon** polygons;
    f32 minX;
    f32 minY;
    f32 maxX;
    f32 maxY;
}

/**/
struct _spSkeletonBounds {
    spSkeletonBounds super;
    i32 capacity;
}

struct spTriangulator {
    spArrayFloatArray* convexPolygons;
    spArrayShortArray* convexPolygonsIndices;
    spShortArray* indicesArray;
    spIntArray* isConcaveArray;
    spShortArray* triangles;
    spArrayFloatArray* polygonPool;
    spArrayShortArray* polygonIndicesPool;
}

struct spSkeletonClipping {
    spTriangulator* triangulator;
    spFloatArray* clippingPolygon;
    spFloatArray* clipOutput;
    spFloatArray* clippedVertices;
    spFloatArray* clippedUVs;
    spUnsignedShortArray* clippedTriangles;
    spFloatArray* scratch;
    spClippingAttachment* clipAttachment;
    spArrayFloatArray* clippingPolygons;
}

struct spSkeletonJson {
    f32 scale;
    spAttachmentLoader* attachmentLoader;
    u8* error;
}

struct _spLinkedMesh {
    u8* parent;
    u8* skin;
    i32 slotIndex;
    spMeshAttachment* mesh;
    i32 inheritTimeline;
}

struct _spSkeletonJson {
    spSkeletonJson super;
    i32 ownsLoader;
    i32 linkedMeshCount;
    i32 linkedMeshCapacity;
    _spLinkedMesh* linkedMeshes;
}

/******************************************************************************
 * Spine Runtimes License Agreement
 * Last updated July 28, 2023. Replaces all prior versions.
 *
 * Copyright (c) 2013-2023, Esoteric Software LLC
 *
 * Integration of the Spine Runtimes into software or otherwise creating
 * derivative works of the Spine Runtimes is permitted under the terms and
 * conditions of Section 2 of the Spine Editor License Agreement:
 * http://esotericsoftware.com/spine-editor-license
 *
 * Otherwise, it is permitted to integrate the Spine Runtimes into software or
 * otherwise create derivative works of the Spine Runtimes (collectively,
 * "Products"), provided that each user of the Products must obtain their own
 * Spine Editor license and redistribution of the Products in any form must
 * include this license and copyright notice.
 *
 * THE SPINE RUNTIMES ARE PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
 * BUSINESS INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THE
 * SPINE RUNTIMES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

spPropertyIdArray* spPropertyIdArray_create(i32 initialCapacity) {
    var array = cast(spPropertyIdArray*, _spCalloc(1, cast(u64, sizeof(spPropertyIdArray)), "extension.h", 87));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spPropertyId*, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spPropertyId)), "extension.h", 87));
    return array;
}

void spPropertyIdArray_dispose(spPropertyIdArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spPropertyIdArray_clear(spPropertyIdArray* self) {
    self.size = 0;
}

spPropertyIdArray* spPropertyIdArray_setSize(spPropertyIdArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spPropertyId*, _spRealloc(self.items, cast(u64, sizeof(spPropertyId) * self.capacity)));
    }
    return self;
}

void spPropertyIdArray_ensureCapacity(spPropertyIdArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spPropertyId*, _spRealloc(self.items, cast(u64, sizeof(spPropertyId) * self.capacity)));
}

void spPropertyIdArray_add(spPropertyIdArray* self, spPropertyId value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spPropertyId*, _spRealloc(self.items, cast(u64, sizeof(spPropertyId) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spPropertyIdArray_addAll(spPropertyIdArray* self, spPropertyIdArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spPropertyIdArray_add(self, other.items[i]);
    }
}

void spPropertyIdArray_addAllValues(spPropertyIdArray* self, spPropertyId* values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spPropertyIdArray_add(self, values[i]);
    }
}

void spPropertyIdArray_removeAt(spPropertyIdArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spPropertyId) * (self.size - index)));
}

i32 spPropertyIdArray_contains(spPropertyIdArray* self, spPropertyId value) {
    spPropertyId* items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spPropertyId spPropertyIdArray_pop(spPropertyIdArray* self) {
    spPropertyId item = self.items[--self.size];
    return item;
}

spPropertyId spPropertyIdArray_peek(spPropertyIdArray* self) {
    return self.items[self.size - 1];
}

spTimelineArray* spTimelineArray_create(i32 initialCapacity) {
    var array = cast(spTimelineArray*, _spCalloc(1, cast(u64, sizeof(spTimelineArray)), "extension.h", 87));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spTimeline**, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spTimeline*)), "extension.h", 87));
    return array;
}

void spTimelineArray_dispose(spTimelineArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spTimelineArray_clear(spTimelineArray* self) {
    self.size = 0;
}

spTimelineArray* spTimelineArray_setSize(spTimelineArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spTimeline**, _spRealloc(self.items, cast(u64, sizeof(spTimeline*) * self.capacity)));
    }
    return self;
}

void spTimelineArray_ensureCapacity(spTimelineArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spTimeline**, _spRealloc(self.items, cast(u64, sizeof(spTimeline*) * self.capacity)));
}

void spTimelineArray_add(spTimelineArray* self, spTimeline* value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spTimeline**, _spRealloc(self.items, cast(u64, sizeof(spTimeline*) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spTimelineArray_addAll(spTimelineArray* self, spTimelineArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spTimelineArray_add(self, other.items[i]);
    }
}

void spTimelineArray_addAllValues(spTimelineArray* self, spTimeline** values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spTimelineArray_add(self, values[i]);
    }
}

void spTimelineArray_removeAt(spTimelineArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spTimeline*) * (self.size - index)));
}

i32 spTimelineArray_contains(spTimelineArray* self, spTimeline* value) {
    spTimeline** items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spTimeline* spTimelineArray_pop(spTimelineArray* self) {
    spTimeline* item = self.items[--self.size];
    return item;
}

spTimeline* spTimelineArray_peek(spTimelineArray* self) {
    return self.items[self.size - 1];
}

spAnimation* spAnimation_create(u8* name, spTimelineArray* timelines, f32 duration) {
    i32 i;
    i32 n;
    i32 totalCount = 0;
    var self = cast(spAnimation*, _spCalloc(1, cast(u64, sizeof(spAnimation)), "extension.h", 87));
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 83));
    strcpy(self.name, name);
    self.timelines = timelines != null ? timelines : spTimelineArray_create(1);
    timelines = self.timelines;
    {
        i = 0;
        for n = timelines.size; i < n; i++ {
            totalCount += timelines.items[i].propertyIdsCount;
        }
    }
    self.timelineIds = spPropertyIdArray_create(totalCount);
    {
        i = 0;
        for n = timelines.size; i < n; i++ {
            spPropertyIdArray_addAllValues(self.timelineIds, timelines.items[i].propertyIds, 0, timelines.items[i].propertyIdsCount);
        }
    }
    self.duration = duration;
    return self;
}

void spAnimation_dispose(spAnimation* self) {
    i32 i;
    for i = 0; i < self.timelines.size; ++i {
        spTimeline_dispose(self.timelines.items[i]);
    }
    spTimelineArray_dispose(self.timelines);
    spPropertyIdArray_dispose(self.timelineIds);
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self));
}

i32 spAnimation_hasTimeline(spAnimation* self, spPropertyId* ids, i32 idsCount) {
    i32 i;
    i32 n;
    i32 ii;
    {
        i = 0;
        for n = self.timelineIds.size; i < n; i++ {
            for ii = 0; ii < idsCount; ii++ {
                if self.timelineIds.items[i] == ids[ii] {
                    return 1;
                }
            }
        }
    }
    return 0;
}

void spAnimation_apply(spAnimation* self, spSkeleton* skeleton, f32 lastTime, f32 time, i32 loop, spEvent** events, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    i32 i;
    i32 n = self.timelines.size;
    if loop && self.duration != 0.0f {
        time = fmodf(time, self.duration);
        if lastTime > 0.0f {
            lastTime = fmodf(lastTime, self.duration);
        }
    }
    for i = 0; i < n; ++i {
        spTimeline_apply(self.timelines.items[i], skeleton, lastTime, time, events, eventsCount, alpha, blend, direction);
    }
}

private {
i32 search(spFloatArray* values, f32 time) {
    i32 i;
    i32 n;
    f32* items = values.items;
    {
        i = 1;
        for n = values.size; i < n; i++ {
            if items[i] > time {
                return i - 1;
            }
        }
    }
    return values.size - 1;
}

i32 search2(spFloatArray* values, f32 time, i32 step) {
    i32 i;
    i32 n;
    f32* items = values.items;
    {
        i = step;
        for n = values.size; i < n; i += step {
            if items[i] > time {
                return i - step;
            }
        }
    }
    return values.size - step;
}
}

/**/
void _spTimeline_init(spTimeline* self, i32 frameCount, i32 frameEntries, spPropertyId* propertyIds, i32 propertyIdsCount, spTimelineType type, fn(spTimeline*): void dispose, fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void apply, fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void setBezier) {
    i32 i;
    self.frames = spFloatArray_create(frameCount * frameEntries);
    self.frames.size = frameCount * frameEntries;
    self.frameCount = frameCount;
    self.frameEntries = frameEntries;
    for i = 0; i < propertyIdsCount; i++ {
        self.propertyIds[i] = propertyIds[i];
    }
    self.propertyIdsCount = propertyIdsCount;
    self.type = type;
    self.vtable.dispose = dispose;
    self.vtable.apply = apply;
    self.vtable.setBezier = setBezier;
}

void spTimeline_dispose(spTimeline* self) {
    self.vtable.dispose(self);
    spFloatArray_dispose(self.frames);
    _spFree(cast(void*, self));
}

void spTimeline_apply(spTimeline* self, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    self.vtable.apply(self, skeleton, lastTime, time, firedEvents, eventsCount, alpha, blend, direction);
}

void spTimeline_setBezier(spTimeline* self, i32 bezier, i32 frame, f32 value, f32 time1, f32 value1, f32 cx1, f32 cy1, f32 cx2, f32 cy2, f32 time2, f32 value2) {
    if self.vtable.setBezier != null {
        self.vtable.setBezier(self, bezier, frame, value, time1, value1, cx1, cy1, cx2, cy2, time2, value2);
    }
}

f32 spTimeline_getDuration(spTimeline* self) {
    return self.frames.items[self.frames.size - self.frameEntries];
}

/**/
void _spCurveTimeline_init(spCurveTimeline* self, i32 frameCount, i32 frameEntries, i32 bezierCount, spPropertyId* propertyIds, i32 propertyIdsCount, spTimelineType type, fn(spTimeline*): void dispose, fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void apply, fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void setBezier) {
    _spTimeline_init(&self.super, frameCount, frameEntries, propertyIds, propertyIdsCount, type, dispose, apply, cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, setBezier));
    self.curves = spFloatArray_create(frameCount + bezierCount * 18);
    self.curves.size = frameCount + bezierCount * 18;
    self.curves.items[frameCount - 1] = 1.0f;
}

void _spCurveTimeline_dispose(spTimeline* self) {
    spFloatArray_dispose(cast(spCurveTimeline*, self).curves);
}

void _spCurveTimeline_setBezier(spTimeline* timeline, i32 bezier, i32 frame, f32 value, f32 time1, f32 value1, f32 cx1, f32 cy1, f32 cx2, f32 cy2, f32 time2, f32 value2) {
    var self = cast(spCurveTimeline*, timeline);
    f32 tmpx;
    f32 tmpy;
    f32 dddx;
    f32 dddy;
    f32 ddx;
    f32 ddy;
    f32 dx;
    f32 dy;
    f32 x;
    f32 y;
    i32 i = self.super.frameCount + bezier * 18;
    i32 n;
    f32* curves = self.curves.items;
    if value == 0.0f {
        curves[frame] = cast(f32, 2 + i);
    }
    tmpx = cast(f32, (time1 - cx1 * 2.0f + cx2) * 0.03);
    tmpy = cast(f32, (value1 - cy1 * 2.0f + cy2) * 0.03);
    dddx = cast(f32, ((cx1 - cx2) * 3.0f - time1 + time2) * 0.006);
    dddy = cast(f32, ((cy1 - cy2) * 3.0f - value1 + value2) * 0.006);
    ddx = tmpx * 2.0f + dddx;
    ddy = tmpy * 2.0f + dddy;
    dx = cast(f32, (cx1 - time1) * 0.3 + tmpx + dddx * 0.16666667);
    dy = cast(f32, (cy1 - value1) * 0.3 + tmpy + dddy * 0.16666667);
    x = time1 + dx;
    y = value1 + dy;
    for n = i + 18; i < n; i += 2 {
        curves[i] = x;
        curves[i + 1] = y;
        dx += ddx;
        dy += ddy;
        ddx += dddx;
        ddy += dddy;
        x += dx;
        y += dy;
    }
}

f32 _spCurveTimeline_getBezierValue(spCurveTimeline* self, f32 time, i32 frameIndex, i32 valueOffset, i32 i) {
    f32* curves = self.curves.items;
    f32* frames = self.super.frames.items;
    f32 x;
    f32 y;
    i32 n;
    if curves[i] > time {
        x = frames[frameIndex];
        y = frames[frameIndex + valueOffset];
        return y + (time - x) / (curves[i] - x) * (curves[i + 1] - y);
    }
    n = i + 18;
    for i += 2; i < n; i += 2 {
        if curves[i] >= time {
            x = curves[i - 2];
            y = curves[i - 1];
            return y + (time - x) / (curves[i] - x) * (curves[i + 1] - y);
        }
    }
    frameIndex += self.super.frameEntries;
    x = curves[n - 2];
    y = curves[n - 1];
    return y + (time - x) / (frames[frameIndex] - x) * (frames[frameIndex + valueOffset] - y);
}

void spCurveTimeline_setLinear(spCurveTimeline* self, i32 frame) {
    self.curves.items[frame] = 0.0f;
}

void spCurveTimeline_setStepped(spCurveTimeline* self, i32 frame) {
    self.curves.items[frame] = 1.0f;
}

void spCurveTimeline1_setFrame(spCurveTimeline1* self, i32 frame, f32 time, f32 value) {
    f32* frames = self.super.frames.items;
    frame <<= 1;
    frames[frame] = time;
    frames[frame + 1] = value;
}

f32 spCurveTimeline1_getCurveValue(spCurveTimeline1* self, f32 time) {
    f32* frames = self.super.frames.items;
    f32* curves = self.curves.items;
    i32 i = self.super.frames.size - 2;
    i32 ii;
    i32 curveType;
    for ii = 2; ii <= i; ii += 2 {
        if frames[ii] > time {
            i = ii - 2;
            break;
        }
    }
    curveType = cast(i32, curves[i >> 1]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                f32 value = frames[i + 1];
                return value + (time - before) / (frames[i + 2] - before) * (frames[i + 2 + 1] - value);
            }
        }
        case 1: {
            return frames[i + 1];
        }
    }
    return _spCurveTimeline_getBezierValue(self, time, i, 1, curveType - 2);
}

f32 spCurveTimeline1_getRelativeValue(spCurveTimeline1* self, f32 time, f32 alpha, spMixBlend blend, f32 current, f32 setup) {
    f32* frames = self.super.frames.items;
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                return setup;
            }
            case SP_MIX_BLEND_FIRST: {
                return current + (setup - current) * alpha;
            }
            default: {
                return current;
            }
        }
    }
    f32 value = spCurveTimeline1_getCurveValue(self, time);
    switch blend {
        case SP_MIX_BLEND_SETUP: {
            return setup + value * alpha;
        }
        case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
            value += setup - current;
        }
        case SP_MIX_BLEND_ADD: {
        }
    }
    return current + value * alpha;
}

f32 spCurveTimeline1_getAbsoluteValue(spCurveTimeline1* self, f32 time, f32 alpha, spMixBlend blend, f32 current, f32 setup) {
    f32* frames = self.super.frames.items;
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                return setup;
            }
            case SP_MIX_BLEND_FIRST: {
                return current + (setup - current) * alpha;
            }
            default: {
                return current;
            }
        }
    }
    f32 value = spCurveTimeline1_getCurveValue(self, time);
    if blend == SP_MIX_BLEND_SETUP {
        return setup + (value - setup) * alpha;
    }
    return current + (value - current) * alpha;
}

f32 spCurveTimeline1_getAbsoluteValue2(spCurveTimeline1* self, f32 time, f32 alpha, spMixBlend blend, f32 current, f32 setup, f32 value) {
    f32* frames = self.super.frames.items;
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                return setup;
            }
            case SP_MIX_BLEND_FIRST: {
                return current + (setup - current) * alpha;
            }
            default: {
                return current;
            }
        }
    }
    if blend == SP_MIX_BLEND_SETUP {
        return setup + (value - setup) * alpha;
    }
    return current + (value - current) * alpha;
}

f32 spCurveTimeline1_getScaleValue(spCurveTimeline1* self, f32 time, f32 alpha, spMixBlend blend, spMixDirection direction, f32 current, f32 setup) {
    f32* frames = self.super.frames.items;
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                return setup;
            }
            case SP_MIX_BLEND_FIRST: {
                return current + (setup - current) * alpha;
            }
            default: {
                return current;
            }
        }
    }
    f32 value = spCurveTimeline1_getCurveValue(self, time) * setup;
    if alpha == 1.0f {
        if blend == SP_MIX_BLEND_ADD {
            return current + value - setup;
        }
        return value;
    }
    if direction == SP_MIX_DIRECTION_OUT {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                return setup + ((value < 0.0f ? -value : value) * (setup < 0.0f ? -1.0f : setup > 0.0f ? 1.0f : 0.0f) - setup) * alpha;
            }
            case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
                return current + ((value < 0.0f ? -value : value) * (current < 0.0f ? -1.0f : current > 0.0f ? 1.0f : 0.0f) - current) * alpha;
            }
            default: {
            }
        }
    } else {
        f32 s;
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                s = (setup < 0.0f ? -setup : setup) * (value < 0.0f ? -1.0f : value > 0.0f ? 1.0f : 0.0f);
                return s + (value - s) * alpha;
            }
            case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
                s = (current < 0.0f ? -current : current) * (value < 0.0f ? -1.0f : value > 0.0f ? 1.0f : 0.0f);
                return s + (value - s) * alpha;
            }
            default: {
            }
        }
    }
    return current + (value - setup) * alpha;
}

void spCurveTimeline2_setFrame(spCurveTimeline1* self, i32 frame, f32 time, f32 value1, f32 value2) {
    f32* frames = self.super.frames.items;
    frame *= 3;
    frames[frame] = time;
    frames[frame + 1] = value1;
    frames[frame + 2] = value2;
}

/**/
void _spRotateTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spRotateTimeline*, timeline);
    spBone* bone = skeleton.bones[self.boneIndex];
    if bone.active != 0 {
        bone.rotation = spCurveTimeline1_getRelativeValue(&self.super, time, alpha, blend, bone.rotation, bone.data.rotation);
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spRotateTimeline* spRotateTimeline_create(i32 frameCount, i32 bezierCount, i32 boneIndex) {
    var timeline = cast(spRotateTimeline*, _spCalloc(1, cast(u64, sizeof(spRotateTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_ROTATE) << 32 | cast(u64, boneIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 2, bezierCount, ids, 1, SP_TIMELINE_ROTATE, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spRotateTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.boneIndex = boneIndex;
    return timeline;
}

void spRotateTimeline_setFrame(spRotateTimeline* self, i32 frame, f32 time, f32 degrees) {
    spCurveTimeline1_setFrame(&self.super, frame, time, degrees);
}

/**/
void _spTranslateTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    spBone* bone;
    f32 x;
    f32 y;
    f32 t;
    i32 i;
    i32 curveType;
    var self = cast(spTranslateTimeline*, timeline);
    f32* frames = self.super.super.frames.items;
    f32* curves = self.super.curves.items;
    bone = skeleton.bones[self.boneIndex];
    if bone.active == 0 {
        return;
    }
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                bone.x = bone.data.x;
                bone.y = bone.data.y;
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                bone.x += (bone.data.x - bone.x) * alpha;
                bone.y += (bone.data.y - bone.y) * alpha;
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    i = search2(self.super.super.frames, time, 3);
    curveType = cast(i32, curves[i / 3]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                x = frames[i + 1];
                y = frames[i + 2];
                t = (time - before) / (frames[i + 3] - before);
                x += (frames[i + 3 + 1] - x) * t;
                y += (frames[i + 3 + 2] - y) * t;
                break case;
            }
        }
        case 1: {
            {
                x = frames[i + 1];
                y = frames[i + 2];
                break case;
            }
        }
        default: {
            {
                x = _spCurveTimeline_getBezierValue(&self.super, time, i, 1, curveType - 2);
                y = _spCurveTimeline_getBezierValue(&self.super, time, i, 2, curveType + 18 - 2);
            }
        }
    }
    switch blend {
        case SP_MIX_BLEND_SETUP: {
            bone.x = bone.data.x + x * alpha;
            bone.y = bone.data.y + y * alpha;
        }
        case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
            bone.x += (bone.data.x + x - bone.x) * alpha;
            bone.y += (bone.data.y + y - bone.y) * alpha;
        }
        case SP_MIX_BLEND_ADD: {
            bone.x += x * alpha;
            bone.y += y * alpha;
        }
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spTranslateTimeline* spTranslateTimeline_create(i32 frameCount, i32 bezierCount, i32 boneIndex) {
    var timeline = cast(spTranslateTimeline*, _spCalloc(1, cast(u64, sizeof(spTranslateTimeline)), "extension.h", 87));
    noinit spPropertyId[2] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_X) << 32 | cast(u64, boneIndex);
    ids[1] = cast(spPropertyId, SP_PROPERTY_Y) << 32 | cast(u64, boneIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 3, bezierCount, ids, 2, SP_TIMELINE_TRANSLATE, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spTranslateTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.boneIndex = boneIndex;
    return timeline;
}

void spTranslateTimeline_setFrame(spTranslateTimeline* self, i32 frame, f32 time, f32 x, f32 y) {
    spCurveTimeline2_setFrame(&self.super, frame, time, x, y);
}

/**/
void _spTranslateXTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    spBone* bone;
    f32 x;
    var self = cast(spTranslateXTimeline*, timeline);
    f32* frames = self.super.super.frames.items;
    bone = skeleton.bones[self.boneIndex];
    if bone.active == 0 {
        return;
    }
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                bone.x = bone.data.x;
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                bone.x += (bone.data.x - bone.x) * alpha;
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    x = spCurveTimeline1_getCurveValue(&self.super, time);
    switch blend {
        case SP_MIX_BLEND_SETUP: {
            bone.x = bone.data.x + x * alpha;
        }
        case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
            bone.x += (bone.data.x + x - bone.x) * alpha;
        }
        case SP_MIX_BLEND_ADD: {
            bone.x += x * alpha;
        }
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spTranslateXTimeline* spTranslateXTimeline_create(i32 frameCount, i32 bezierCount, i32 boneIndex) {
    var timeline = cast(spTranslateXTimeline*, _spCalloc(1, cast(u64, sizeof(spTranslateXTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_X) << 32 | cast(u64, boneIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 2, bezierCount, ids, 1, SP_TIMELINE_TRANSLATEX, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spTranslateXTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.boneIndex = boneIndex;
    return timeline;
}

void spTranslateXTimeline_setFrame(spTranslateXTimeline* self, i32 frame, f32 time, f32 x) {
    spCurveTimeline1_setFrame(&self.super, frame, time, x);
}

/**/
void _spTranslateYTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    spBone* bone;
    f32 y;
    var self = cast(spTranslateYTimeline*, timeline);
    f32* frames = self.super.super.frames.items;
    bone = skeleton.bones[self.boneIndex];
    if bone.active == 0 {
        return;
    }
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                bone.y = bone.data.y;
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                bone.y += (bone.data.y - bone.y) * alpha;
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    y = spCurveTimeline1_getCurveValue(&self.super, time);
    switch blend {
        case SP_MIX_BLEND_SETUP: {
            bone.y = bone.data.y + y * alpha;
        }
        case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
            bone.y += (bone.data.y + y - bone.y) * alpha;
        }
        case SP_MIX_BLEND_ADD: {
            bone.y += y * alpha;
        }
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spTranslateYTimeline* spTranslateYTimeline_create(i32 frameCount, i32 bezierCount, i32 boneIndex) {
    var timeline = cast(spTranslateYTimeline*, _spCalloc(1, cast(u64, sizeof(spTranslateYTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_Y) << 32 | cast(u64, boneIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 2, bezierCount, ids, 1, SP_TIMELINE_TRANSLATEY, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spTranslateYTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.boneIndex = boneIndex;
    return timeline;
}

void spTranslateYTimeline_setFrame(spTranslateYTimeline* self, i32 frame, f32 time, f32 y) {
    spCurveTimeline1_setFrame(&self.super, frame, time, y);
}

/**/
void _spScaleTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    spBone* bone;
    i32 i;
    i32 curveType;
    f32 x;
    f32 y;
    f32 t;
    var self = cast(spScaleTimeline*, timeline);
    f32* frames = self.super.super.frames.items;
    f32* curves = self.super.curves.items;
    bone = skeleton.bones[self.boneIndex];
    if bone.active == 0 {
        return;
    }
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                bone.scaleX = bone.data.scaleX;
                bone.scaleY = bone.data.scaleY;
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                bone.scaleX += (bone.data.scaleX - bone.scaleX) * alpha;
                bone.scaleY += (bone.data.scaleY - bone.scaleY) * alpha;
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    i = search2(self.super.super.frames, time, 3);
    curveType = cast(i32, curves[i / 3]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                x = frames[i + 1];
                y = frames[i + 2];
                t = (time - before) / (frames[i + 3] - before);
                x += (frames[i + 3 + 1] - x) * t;
                y += (frames[i + 3 + 2] - y) * t;
                break case;
            }
        }
        case 1: {
            {
                x = frames[i + 1];
                y = frames[i + 2];
                break case;
            }
        }
        default: {
            {
                x = _spCurveTimeline_getBezierValue(&self.super, time, i, 1, curveType - 2);
                y = _spCurveTimeline_getBezierValue(&self.super, time, i, 2, curveType + 18 - 2);
            }
        }
    }
    x *= bone.data.scaleX;
    y *= bone.data.scaleY;
    if alpha == 1.0f {
        if blend == SP_MIX_BLEND_ADD {
            bone.scaleX += x - bone.data.scaleX;
            bone.scaleY += y - bone.data.scaleY;
        } else {
            bone.scaleX = x;
            bone.scaleY = y;
        }
    } else {
        f32 bx;
        f32 by;
        if direction == SP_MIX_DIRECTION_OUT {
            switch blend {
                case SP_MIX_BLEND_SETUP: {
                    bx = bone.data.scaleX;
                    by = bone.data.scaleY;
                    bone.scaleX = bx + ((x < 0.0f ? -x : x) * (bx < 0.0f ? -1.0f : bx > 0.0f ? 1.0f : 0.0f) - bx) * alpha;
                    bone.scaleY = by + ((y < 0.0f ? -y : y) * (by < 0.0f ? -1.0f : by > 0.0f ? 1.0f : 0.0f) - by) * alpha;
                }
                case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
                    bx = bone.scaleX;
                    by = bone.scaleY;
                    bone.scaleX = bx + ((x < 0.0f ? -x : x) * (bx < 0.0f ? -1.0f : bx > 0.0f ? 1.0f : 0.0f) - bx) * alpha;
                    bone.scaleY = by + ((y < 0.0f ? -y : y) * (by < 0.0f ? -1.0f : by > 0.0f ? 1.0f : 0.0f) - by) * alpha;
                }
                case SP_MIX_BLEND_ADD: {
                    bone.scaleX += (x - bone.data.scaleX) * alpha;
                    bone.scaleY += (y - bone.data.scaleY) * alpha;
                }
            }
        } else {
            switch blend {
                case SP_MIX_BLEND_SETUP: {
                    bx = (bone.data.scaleX < 0.0f ? -bone.data.scaleX : bone.data.scaleX) * (x < 0.0f ? -1.0f : x > 0.0f ? 1.0f : 0.0f);
                    by = (bone.data.scaleY < 0.0f ? -bone.data.scaleY : bone.data.scaleY) * (y < 0.0f ? -1.0f : y > 0.0f ? 1.0f : 0.0f);
                    bone.scaleX = bx + (x - bx) * alpha;
                    bone.scaleY = by + (y - by) * alpha;
                }
                case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
                    bx = (bone.scaleX < 0.0f ? -bone.scaleX : bone.scaleX) * (x < 0.0f ? -1.0f : x > 0.0f ? 1.0f : 0.0f);
                    by = (bone.scaleY < 0.0f ? -bone.scaleY : bone.scaleY) * (y < 0.0f ? -1.0f : y > 0.0f ? 1.0f : 0.0f);
                    bone.scaleX = bx + (x - bx) * alpha;
                    bone.scaleY = by + (y - by) * alpha;
                }
                case SP_MIX_BLEND_ADD: {
                    bone.scaleX += (x - bone.data.scaleX) * alpha;
                    bone.scaleY += (y - bone.data.scaleY) * alpha;
                }
            }
        }
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
}

spScaleTimeline* spScaleTimeline_create(i32 frameCount, i32 bezierCount, i32 boneIndex) {
    var timeline = cast(spScaleTimeline*, _spCalloc(1, cast(u64, sizeof(spScaleTimeline)), "extension.h", 87));
    noinit spPropertyId[2] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_SCALEX) << 32 | cast(u64, boneIndex);
    ids[1] = cast(spPropertyId, SP_PROPERTY_SCALEY) << 32 | cast(u64, boneIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 3, bezierCount, ids, 2, SP_TIMELINE_SCALE, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spScaleTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.boneIndex = boneIndex;
    return timeline;
}

void spScaleTimeline_setFrame(spScaleTimeline* self, i32 frame, f32 time, f32 x, f32 y) {
    spCurveTimeline2_setFrame(&self.super, frame, time, x, y);
}

/**/
void _spScaleXTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spScaleXTimeline*, timeline);
    spBone* bone = skeleton.bones[self.boneIndex];
    if bone.active != 0 {
        bone.scaleX = spCurveTimeline1_getScaleValue(&self.super, time, alpha, blend, direction, bone.scaleX, bone.data.scaleX);
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
}

spScaleXTimeline* spScaleXTimeline_create(i32 frameCount, i32 bezierCount, i32 boneIndex) {
    var timeline = cast(spScaleXTimeline*, _spCalloc(1, cast(u64, sizeof(spScaleXTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_SCALEX) << 32 | cast(u64, boneIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 2, bezierCount, ids, 1, SP_TIMELINE_SCALEX, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spScaleXTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.boneIndex = boneIndex;
    return timeline;
}

void spScaleXTimeline_setFrame(spScaleXTimeline* self, i32 frame, f32 time, f32 y) {
    spCurveTimeline1_setFrame(&self.super, frame, time, y);
}

/**/
void _spScaleYTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spScaleYTimeline*, timeline);
    spBone* bone = skeleton.bones[self.boneIndex];
    if bone.active != 0 {
        bone.scaleY = spCurveTimeline1_getScaleValue(&self.super, time, alpha, blend, direction, bone.scaleX, bone.data.scaleY);
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
}

spScaleYTimeline* spScaleYTimeline_create(i32 frameCount, i32 bezierCount, i32 boneIndex) {
    var timeline = cast(spScaleYTimeline*, _spCalloc(1, cast(u64, sizeof(spScaleYTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_SCALEY) << 32 | cast(u64, boneIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 2, bezierCount, ids, 1, SP_TIMELINE_SCALEY, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spScaleYTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.boneIndex = boneIndex;
    return timeline;
}

void spScaleYTimeline_setFrame(spScaleYTimeline* self, i32 frame, f32 time, f32 y) {
    spCurveTimeline1_setFrame(&self.super, frame, time, y);
}

/**/
void _spShearTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    spBone* bone;
    f32 x;
    f32 y;
    f32 t;
    i32 i;
    i32 curveType;
    var self = cast(spShearTimeline*, timeline);
    f32* frames = self.super.super.frames.items;
    f32* curves = self.super.curves.items;
    bone = skeleton.bones[self.boneIndex];
    if bone.active == 0 {
        return;
    }
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                bone.shearX = bone.data.shearX;
                bone.shearY = bone.data.shearY;
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                bone.shearX += (bone.data.shearX - bone.shearX) * alpha;
                bone.shearY += (bone.data.shearY - bone.shearY) * alpha;
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    i = search2(self.super.super.frames, time, 3);
    curveType = cast(i32, curves[i / 3]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                x = frames[i + 1];
                y = frames[i + 2];
                t = (time - before) / (frames[i + 3] - before);
                x += (frames[i + 3 + 1] - x) * t;
                y += (frames[i + 3 + 2] - y) * t;
                break case;
            }
        }
        case 1: {
            {
                x = frames[i + 1];
                y = frames[i + 2];
                break case;
            }
        }
        default: {
            {
                x = _spCurveTimeline_getBezierValue(&self.super, time, i, 1, curveType - 2);
                y = _spCurveTimeline_getBezierValue(&self.super, time, i, 2, curveType + 18 - 2);
            }
        }
    }
    switch blend {
        case SP_MIX_BLEND_SETUP: {
            bone.shearX = bone.data.shearX + x * alpha;
            bone.shearY = bone.data.shearY + y * alpha;
        }
        case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
            bone.shearX += (bone.data.shearX + x - bone.shearX) * alpha;
            bone.shearY += (bone.data.shearY + y - bone.shearY) * alpha;
        }
        case SP_MIX_BLEND_ADD: {
            bone.shearX += x * alpha;
            bone.shearY += y * alpha;
        }
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spShearTimeline* spShearTimeline_create(i32 frameCount, i32 bezierCount, i32 boneIndex) {
    var timeline = cast(spShearTimeline*, _spCalloc(1, cast(u64, sizeof(spShearTimeline)), "extension.h", 87));
    noinit spPropertyId[2] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_SHEARX) << 32 | cast(u64, boneIndex);
    ids[1] = cast(spPropertyId, SP_PROPERTY_SHEARY) << 32 | cast(u64, boneIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 3, bezierCount, ids, 2, SP_TIMELINE_SHEAR, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spShearTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.boneIndex = boneIndex;
    return timeline;
}

void spShearTimeline_setFrame(spShearTimeline* self, i32 frame, f32 time, f32 x, f32 y) {
    spCurveTimeline2_setFrame(&self.super, frame, time, x, y);
}

/**/
void _spShearXTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spShearXTimeline*, timeline);
    spBone* bone = skeleton.bones[self.boneIndex];
    if bone.active != 0 {
        bone.shearX = spCurveTimeline1_getRelativeValue(&self.super, time, alpha, blend, bone.shearX, bone.data.shearX);
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spShearXTimeline* spShearXTimeline_create(i32 frameCount, i32 bezierCount, i32 boneIndex) {
    var timeline = cast(spShearXTimeline*, _spCalloc(1, cast(u64, sizeof(spShearXTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_SHEARX) << 32 | cast(u64, boneIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 2, bezierCount, ids, 1, SP_TIMELINE_SHEARX, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spShearXTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.boneIndex = boneIndex;
    return timeline;
}

void spShearXTimeline_setFrame(spShearXTimeline* self, i32 frame, f32 time, f32 x) {
    spCurveTimeline1_setFrame(&self.super, frame, time, x);
}

/**/
void _spShearYTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spShearYTimeline*, timeline);
    spBone* bone = skeleton.bones[self.boneIndex];
    if bone.active != 0 {
        bone.shearY = spCurveTimeline1_getRelativeValue(&self.super, time, alpha, blend, bone.shearY, bone.data.shearY);
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spShearYTimeline* spShearYTimeline_create(i32 frameCount, i32 bezierCount, i32 boneIndex) {
    var timeline = cast(spShearYTimeline*, _spCalloc(1, cast(u64, sizeof(spShearYTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_SHEARY) << 32 | cast(u64, boneIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 2, bezierCount, ids, 1, SP_TIMELINE_SHEARY, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spShearYTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.boneIndex = boneIndex;
    return timeline;
}

void spShearYTimeline_setFrame(spShearYTimeline* self, i32 frame, f32 time, f32 y) {
    spCurveTimeline1_setFrame(&self.super, frame, time, y);
}
/**/
private { i32 RGBA_ENTRIES = 5; }
private { i32 COLOR_R = 1; }
private { i32 COLOR_G = 2; }
private { i32 COLOR_B = 3; }
private { i32 COLOR_A = 4; }

void _spRGBATimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    spSlot* slot;
    i32 i;
    i32 curveType;
    f32 r;
    f32 g;
    f32 b;
    f32 a;
    f32 t;
    spColor* color;
    spColor* setup;
    var self = cast(spRGBATimeline*, timeline);
    f32* frames = self.super.super.frames.items;
    f32* curves = self.super.curves.items;
    slot = skeleton.slots[self.slotIndex];
    if slot.bone.active == 0 {
        return;
    }
    if time < frames[0] {
        color = &slot.color;
        setup = &slot.data.color;
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                spColor_setFromColor(color, setup);
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                spColor_addFloats(color, (setup.r - color.r) * alpha, (setup.g - color.g) * alpha, (setup.b - color.b) * alpha, (setup.a - color.a) * alpha);
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    i = search2(self.super.super.frames, time, RGBA_ENTRIES);
    curveType = cast(i32, curves[i / RGBA_ENTRIES]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                r = frames[i + COLOR_R];
                g = frames[i + COLOR_G];
                b = frames[i + COLOR_B];
                a = frames[i + COLOR_A];
                t = (time - before) / (frames[i + RGBA_ENTRIES] - before);
                r += (frames[i + RGBA_ENTRIES + COLOR_R] - r) * t;
                g += (frames[i + RGBA_ENTRIES + COLOR_G] - g) * t;
                b += (frames[i + RGBA_ENTRIES + COLOR_B] - b) * t;
                a += (frames[i + RGBA_ENTRIES + COLOR_A] - a) * t;
                break case;
            }
        }
        case 1: {
            {
                r = frames[i + COLOR_R];
                g = frames[i + COLOR_G];
                b = frames[i + COLOR_B];
                a = frames[i + COLOR_A];
                break case;
            }
        }
        default: {
            {
                r = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_R, curveType - 2);
                g = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_G, curveType + 18 - 2);
                b = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_B, curveType + 18 * 2 - 2);
                a = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_A, curveType + 18 * 3 - 2);
            }
        }
    }
    color = &slot.color;
    if alpha == 1.0f {
        spColor_setFromFloats(color, r, g, b, a);
    } else {
        if blend == SP_MIX_BLEND_SETUP {
            spColor_setFromColor(color, &slot.data.color);
        }
        spColor_addFloats(color, (r - color.r) * alpha, (g - color.g) * alpha, (b - color.b) * alpha, (a - color.a) * alpha);
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spRGBATimeline* spRGBATimeline_create(i32 framesCount, i32 bezierCount, i32 slotIndex) {
    var timeline = cast(spRGBATimeline*, _spCalloc(1, cast(u64, sizeof(spRGBATimeline)), "extension.h", 87));
    noinit spPropertyId[2] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_RGB) << 32 | cast(u64, slotIndex);
    ids[1] = cast(spPropertyId, SP_PROPERTY_ALPHA) << 32 | cast(u64, slotIndex);
    _spCurveTimeline_init(&timeline.super, framesCount, RGBA_ENTRIES, bezierCount, ids, 2, SP_TIMELINE_RGBA, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spRGBATimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.slotIndex = slotIndex;
    return timeline;
}

void spRGBATimeline_setFrame(spRGBATimeline* self, i32 frame, f32 time, f32 r, f32 g, f32 b, f32 a) {
    f32* frames = self.super.super.frames.items;
    frame *= RGBA_ENTRIES;
    frames[frame] = time;
    frames[frame + COLOR_R] = r;
    frames[frame + COLOR_G] = g;
    frames[frame + COLOR_B] = b;
    frames[frame + COLOR_A] = a;
}

/**/
void _spRGBTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    spSlot* slot;
    i32 i;
    i32 curveType;
    f32 r;
    f32 g;
    f32 b;
    f32 t;
    spColor* color;
    spColor* setup;
    var self = cast(spRGBTimeline*, timeline);
    f32* frames = self.super.super.frames.items;
    f32* curves = self.super.curves.items;
    slot = skeleton.slots[self.slotIndex];
    if slot.bone.active == 0 {
        return;
    }
    if time < frames[0] {
        color = &slot.color;
        setup = &slot.data.color;
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                spColor_setFromColor(color, setup);
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                spColor_addFloats(color, (setup.r - color.r) * alpha, (setup.g - color.g) * alpha, (setup.b - color.b) * alpha, (setup.a - color.a) * alpha);
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    i = search2(self.super.super.frames, time, 4);
    curveType = cast(i32, curves[i / 4]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                r = frames[i + COLOR_R];
                g = frames[i + COLOR_G];
                b = frames[i + COLOR_B];
                t = (time - before) / (frames[i + 4] - before);
                r += (frames[i + 4 + COLOR_R] - r) * t;
                g += (frames[i + 4 + COLOR_G] - g) * t;
                b += (frames[i + 4 + COLOR_B] - b) * t;
                break case;
            }
        }
        case 1: {
            {
                r = frames[i + COLOR_R];
                g = frames[i + COLOR_G];
                b = frames[i + COLOR_B];
                break case;
            }
        }
        default: {
            {
                r = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_R, curveType - 2);
                g = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_G, curveType + 18 - 2);
                b = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_B, curveType + 18 * 2 - 2);
            }
        }
    }
    color = &slot.color;
    if alpha == 1.0f {
        color.r = r;
        color.g = g;
        color.b = b;
    } else {
        if blend == SP_MIX_BLEND_SETUP {
            color.r = slot.data.color.r;
            color.g = slot.data.color.g;
            color.b = slot.data.color.b;
        }
        color.r += (r - color.r) * alpha;
        color.g += (g - color.g) * alpha;
        color.b += (b - color.b) * alpha;
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spRGBTimeline* spRGBTimeline_create(i32 framesCount, i32 bezierCount, i32 slotIndex) {
    var timeline = cast(spRGBTimeline*, _spCalloc(1, cast(u64, sizeof(spRGBTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_RGB) << 32 | cast(u64, slotIndex);
    _spCurveTimeline_init(&timeline.super, framesCount, 4, bezierCount, ids, 1, SP_TIMELINE_RGB, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spRGBTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.slotIndex = slotIndex;
    return timeline;
}

void spRGBTimeline_setFrame(spRGBTimeline* self, i32 frame, f32 time, f32 r, f32 g, f32 b) {
    f32* frames = self.super.super.frames.items;
    frame *= 4;
    frames[frame] = time;
    frames[frame + COLOR_R] = r;
    frames[frame + COLOR_G] = g;
    frames[frame + COLOR_B] = b;
}

/**/
void _spAlphaTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    spSlot* slot;
    f32 a;
    spColor* color;
    spColor* setup;
    var self = cast(spAlphaTimeline*, timeline);
    f32* frames = self.super.super.frames.items;
    slot = skeleton.slots[self.slotIndex];
    if slot.bone.active == 0 {
        return;
    }
    if time < frames[0] {
        color = &slot.color;
        setup = &slot.data.color;
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                color.a = setup.a;
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                color.a += (setup.a - color.a) * alpha;
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    a = spCurveTimeline1_getCurveValue(&self.super, time);
    if alpha == 1.0f {
        slot.color.a = a;
    } else {
        if blend == SP_MIX_BLEND_SETUP {
            slot.color.a = slot.data.color.a;
        }
        slot.color.a += (a - slot.color.a) * alpha;
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spAlphaTimeline* spAlphaTimeline_create(i32 frameCount, i32 bezierCount, i32 slotIndex) {
    var timeline = cast(spAlphaTimeline*, _spCalloc(1, cast(u64, sizeof(spAlphaTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_ALPHA) << 32 | cast(u64, slotIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 2, bezierCount, ids, 1, SP_TIMELINE_ALPHA, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spAlphaTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.slotIndex = slotIndex;
    return timeline;
}

void spAlphaTimeline_setFrame(spAlphaTimeline* self, i32 frame, f32 time, f32 alpha) {
    spCurveTimeline1_setFrame(&self.super, frame, time, alpha);
}
/**/
private { i32 RGBA2_ENTRIES = 8; }
private { i32 COLOR_R2 = 5; }
private { i32 COLOR_G2 = 6; }
private { i32 COLOR_B2 = 7; }

void _spRGBA2Timeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    spSlot* slot;
    i32 i;
    i32 curveType;
    f32 r;
    f32 g;
    f32 b;
    f32 a;
    f32 r2;
    f32 g2;
    f32 b2;
    f32 t;
    spColor* light;
    spColor* setupLight;
    spColor* dark;
    spColor* setupDark;
    var self = cast(spRGBA2Timeline*, timeline);
    f32* frames = self.super.super.frames.items;
    f32* curves = self.super.curves.items;
    slot = skeleton.slots[self.slotIndex];
    if slot.bone.active == 0 {
        return;
    }
    if time < frames[0] {
        light = &slot.color;
        dark = slot.darkColor;
        setupLight = &slot.data.color;
        setupDark = slot.data.darkColor;
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                spColor_setFromColor(light, setupLight);
                spColor_setFromFloats3(dark, setupDark.r, setupDark.g, setupDark.b);
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                spColor_addFloats(light, (setupLight.r - light.r) * alpha, (setupLight.g - light.g) * alpha, (setupLight.b - light.b) * alpha, (setupLight.a - light.a) * alpha);
                dark.r += (setupDark.r - dark.r) * alpha;
                dark.g += (setupDark.g - dark.g) * alpha;
                dark.b += (setupDark.b - dark.b) * alpha;
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    r = 0.0f;
    g = 0.0f;
    b = 0.0f;
    a = 0.0f;
    r2 = 0.0f;
    g2 = 0.0f;
    b2 = 0.0f;
    i = search2(self.super.super.frames, time, RGBA2_ENTRIES);
    curveType = cast(i32, curves[i / RGBA2_ENTRIES]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                r = frames[i + COLOR_R];
                g = frames[i + COLOR_G];
                b = frames[i + COLOR_B];
                a = frames[i + COLOR_A];
                r2 = frames[i + COLOR_R2];
                g2 = frames[i + COLOR_G2];
                b2 = frames[i + COLOR_B2];
                t = (time - before) / (frames[i + RGBA2_ENTRIES] - before);
                r += (frames[i + RGBA2_ENTRIES + COLOR_R] - r) * t;
                g += (frames[i + RGBA2_ENTRIES + COLOR_G] - g) * t;
                b += (frames[i + RGBA2_ENTRIES + COLOR_B] - b) * t;
                a += (frames[i + RGBA2_ENTRIES + COLOR_A] - a) * t;
                r2 += (frames[i + RGBA2_ENTRIES + COLOR_R2] - r2) * t;
                g2 += (frames[i + RGBA2_ENTRIES + COLOR_G2] - g2) * t;
                b2 += (frames[i + RGBA2_ENTRIES + COLOR_B2] - b2) * t;
                break case;
            }
        }
        case 1: {
            {
                r = frames[i + COLOR_R];
                g = frames[i + COLOR_G];
                b = frames[i + COLOR_B];
                a = frames[i + COLOR_A];
                r2 = frames[i + COLOR_R2];
                g2 = frames[i + COLOR_G2];
                b2 = frames[i + COLOR_B2];
                break case;
            }
        }
        default: {
            {
                r = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_R, curveType - 2);
                g = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_G, curveType + 18 - 2);
                b = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_B, curveType + 18 * 2 - 2);
                a = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_A, curveType + 18 * 3 - 2);
                r2 = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_R2, curveType + 18 * 4 - 2);
                g2 = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_G2, curveType + 18 * 5 - 2);
                b2 = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_B2, curveType + 18 * 6 - 2);
            }
        }
    }
    light = &slot.color;
    dark = slot.darkColor;
    if alpha == 1.0f {
        spColor_setFromFloats(light, r, g, b, a);
        spColor_setFromFloats3(dark, r2, g2, b2);
    } else {
        if blend == SP_MIX_BLEND_SETUP {
            spColor_setFromColor(light, &slot.data.color);
            spColor_setFromColor(dark, slot.data.darkColor);
        }
        spColor_addFloats(light, (r - light.r) * alpha, (g - light.g) * alpha, (b - light.b) * alpha, (a - light.a) * alpha);
        dark.r += (r2 - dark.r) * alpha;
        dark.g += (g2 - dark.g) * alpha;
        dark.b += (b2 - dark.b) * alpha;
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spRGBA2Timeline* spRGBA2Timeline_create(i32 framesCount, i32 bezierCount, i32 slotIndex) {
    var timeline = cast(spRGBA2Timeline*, _spCalloc(1, cast(u64, sizeof(spRGBA2Timeline)), "extension.h", 87));
    noinit spPropertyId[3] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_RGB) << 32 | cast(u64, slotIndex);
    ids[1] = cast(spPropertyId, SP_PROPERTY_ALPHA) << 32 | cast(u64, slotIndex);
    ids[2] = cast(spPropertyId, SP_PROPERTY_RGB2) << 32 | cast(u64, slotIndex);
    _spCurveTimeline_init(&timeline.super, framesCount, RGBA2_ENTRIES, bezierCount, ids, 3, SP_TIMELINE_RGBA2, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spRGBA2Timeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.slotIndex = slotIndex;
    return timeline;
}

void spRGBA2Timeline_setFrame(spRGBA2Timeline* self, i32 frame, f32 time, f32 r, f32 g, f32 b, f32 a, f32 r2, f32 g2, f32 b2) {
    f32* frames = self.super.super.frames.items;
    frame *= RGBA2_ENTRIES;
    frames[frame] = time;
    frames[frame + COLOR_R] = r;
    frames[frame + COLOR_G] = g;
    frames[frame + COLOR_B] = b;
    frames[frame + COLOR_A] = a;
    frames[frame + COLOR_R2] = r2;
    frames[frame + COLOR_G2] = g2;
    frames[frame + COLOR_B2] = b2;
}
/**/
private { i32 RGB2_ENTRIES = 7; }
private { i32 COLOR2_R2 = 5; }
private { i32 COLOR2_G2 = 6; }
private { i32 COLOR2_B2 = 7; }

void _spRGB2Timeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    spSlot* slot;
    i32 i;
    i32 curveType;
    f32 r;
    f32 g;
    f32 b;
    f32 r2;
    f32 g2;
    f32 b2;
    f32 t;
    spColor* light;
    spColor* setupLight;
    spColor* dark;
    spColor* setupDark;
    var self = cast(spRGB2Timeline*, timeline);
    f32* frames = self.super.super.frames.items;
    f32* curves = self.super.curves.items;
    slot = skeleton.slots[self.slotIndex];
    if slot.bone.active == 0 {
        return;
    }
    if time < frames[0] {
        light = &slot.color;
        dark = slot.darkColor;
        setupLight = &slot.data.color;
        setupDark = slot.data.darkColor;
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                spColor_setFromColor3(light, setupLight);
                spColor_setFromColor3(dark, setupDark);
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                spColor_addFloats3(light, (setupLight.r - light.r) * alpha, (setupLight.g - light.g) * alpha, (setupLight.b - light.b) * alpha);
                dark.r += (setupDark.r - dark.r) * alpha;
                dark.g += (setupDark.g - dark.g) * alpha;
                dark.b += (setupDark.b - dark.b) * alpha;
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    r = 0.0f;
    g = 0.0f;
    b = 0.0f;
    r2 = 0.0f;
    g2 = 0.0f;
    b2 = 0.0f;
    i = search2(self.super.super.frames, time, RGB2_ENTRIES);
    curveType = cast(i32, curves[i / RGB2_ENTRIES]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                r = frames[i + COLOR_R];
                g = frames[i + COLOR_G];
                b = frames[i + COLOR_B];
                r2 = frames[i + COLOR2_R2];
                g2 = frames[i + COLOR2_G2];
                b2 = frames[i + COLOR2_B2];
                t = (time - before) / (frames[i + RGB2_ENTRIES] - before);
                r += (frames[i + RGB2_ENTRIES + COLOR_R] - r) * t;
                g += (frames[i + RGB2_ENTRIES + COLOR_G] - g) * t;
                b += (frames[i + RGB2_ENTRIES + COLOR_B] - b) * t;
                r2 += (frames[i + RGB2_ENTRIES + COLOR2_R2] - r2) * t;
                g2 += (frames[i + RGB2_ENTRIES + COLOR2_G2] - g2) * t;
                b2 += (frames[i + RGB2_ENTRIES + COLOR2_B2] - b2) * t;
                break case;
            }
        }
        case 1: {
            {
                r = frames[i + COLOR_R];
                g = frames[i + COLOR_G];
                b = frames[i + COLOR_B];
                r2 = frames[i + COLOR2_R2];
                g2 = frames[i + COLOR2_G2];
                b2 = frames[i + COLOR2_B2];
                break case;
            }
        }
        default: {
            {
                r = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_R, curveType - 2);
                g = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_G, curveType + 18 - 2);
                b = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR_B, curveType + 18 * 2 - 2);
                r2 = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR2_R2, curveType + 18 * 3 - 2);
                g2 = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR2_G2, curveType + 18 * 4 - 2);
                b2 = _spCurveTimeline_getBezierValue(&self.super, time, i, COLOR2_B2, curveType + 18 * 5 - 2);
            }
        }
    }
    light = &slot.color;
    dark = slot.darkColor;
    if alpha == 1.0f {
        spColor_setFromFloats3(light, r, g, b);
        spColor_setFromFloats3(dark, r2, g2, b2);
    } else {
        if blend == SP_MIX_BLEND_SETUP {
            spColor_setFromColor3(light, &slot.data.color);
            spColor_setFromColor3(dark, slot.data.darkColor);
        }
        spColor_addFloats3(light, (r - light.r) * alpha, (g - light.g) * alpha, (b - light.b) * alpha);
        dark.r += (r2 - dark.r) * alpha;
        dark.g += (g2 - dark.g) * alpha;
        dark.b += (b2 - dark.b) * alpha;
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spRGB2Timeline* spRGB2Timeline_create(i32 framesCount, i32 bezierCount, i32 slotIndex) {
    var timeline = cast(spRGB2Timeline*, _spCalloc(1, cast(u64, sizeof(spRGB2Timeline)), "extension.h", 87));
    noinit spPropertyId[2] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_RGB) << 32 | cast(u64, slotIndex);
    ids[1] = cast(spPropertyId, SP_PROPERTY_RGB2) << 32 | cast(u64, slotIndex);
    _spCurveTimeline_init(&timeline.super, framesCount, RGB2_ENTRIES, bezierCount, ids, 2, SP_TIMELINE_RGB2, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spRGB2Timeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.slotIndex = slotIndex;
    return timeline;
}

void spRGB2Timeline_setFrame(spRGB2Timeline* self, i32 frame, f32 time, f32 r, f32 g, f32 b, f32 r2, f32 g2, f32 b2) {
    f32* frames = self.super.super.frames.items;
    frame *= RGB2_ENTRIES;
    frames[frame] = time;
    frames[frame + COLOR_R] = r;
    frames[frame + COLOR_G] = g;
    frames[frame + COLOR_B] = b;
    frames[frame + COLOR2_R2] = r2;
    frames[frame + COLOR2_G2] = g2;
    frames[frame + COLOR2_B2] = b2;
}

/**/
private {
void _spSetAttachment(spAttachmentTimeline* timeline, spSkeleton* skeleton, spSlot* slot, u8* attachmentName) {
    spSlot_setAttachment(slot, attachmentName == null ? null : spSkeleton_getAttachmentForSlotIndex(skeleton, timeline.slotIndex, attachmentName));
}
}

void _spAttachmentTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    u8* attachmentName;
    var self = cast(spAttachmentTimeline*, timeline);
    f32* frames = self.super.frames.items;
    spSlot* slot = skeleton.slots[self.slotIndex];
    if slot.bone.active == 0 {
        return;
    }
    if direction == SP_MIX_DIRECTION_OUT {
        if blend == SP_MIX_BLEND_SETUP {
            _spSetAttachment(self, skeleton, slot, slot.data.attachmentName);
        }
        return;
    }
    if time < frames[0] {
        if blend == SP_MIX_BLEND_SETUP || blend == SP_MIX_BLEND_FIRST {
            _spSetAttachment(self, skeleton, slot, slot.data.attachmentName);
        }
        return;
    }
    if time < frames[0] {
        if blend == SP_MIX_BLEND_SETUP || blend == SP_MIX_BLEND_FIRST {
            _spSetAttachment(self, skeleton, slot, slot.data.attachmentName);
        }
        return;
    }
    attachmentName = self.attachmentNames[search(self.super.frames, time)];
    _spSetAttachment(self, skeleton, slot, attachmentName);
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore alpha;
}

void _spAttachmentTimeline_dispose(spTimeline* timeline) {
    var self = cast(spAttachmentTimeline*, timeline);
    i32 i;
    for i = 0; i < self.super.frames.size; ++i {
        _spFree(cast(void*, self.attachmentNames[i]));
    }
    _spFree(cast(void*, self.attachmentNames));
}

spAttachmentTimeline* spAttachmentTimeline_create(i32 framesCount, i32 slotIndex) {
    var self = cast(spAttachmentTimeline*, _spCalloc(1, cast(u64, sizeof(spAttachmentTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_ATTACHMENT) << 32 | cast(u64, slotIndex);
    _spTimeline_init(&self.super, framesCount, 1, ids, 1, SP_TIMELINE_ATTACHMENT, cast(fn(spTimeline*): void, _spAttachmentTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spAttachmentTimeline_apply), null);
    self.attachmentNames = cast(u8**, _spCalloc(cast(u64, framesCount), cast(u64, sizeof(u8*)), "extension.h", 87));
    self.slotIndex = slotIndex;
    return self;
}

void spAttachmentTimeline_setFrame(spAttachmentTimeline* self, i32 frame, f32 time, u8* attachmentName) {
    self.super.frames.items[frame] = time;
    _spFree(cast(void*, self.attachmentNames[frame]));
    if attachmentName != null {
        self.attachmentNames[frame] = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(attachmentName) + 1), "extension.h", 83));
        strcpy(self.attachmentNames[frame], attachmentName);
    } else {
        self.attachmentNames[frame] = null;
    }
}

/**/
void _spDeformTimeline_setBezier(spTimeline* timeline, i32 bezier, i32 frame, f32 value, f32 time1, f32 value1, f32 cx1, f32 cy1, f32 cx2, f32 cy2, f32 time2, f32 value2) {
    var self = cast(spDeformTimeline*, timeline);
    i32 n;
    i32 i = self.super.super.frameCount + bezier * 18;
    f32* curves = self.super.curves.items;
    var tmpx = cast(f32, (time1 - cx1 * 2.0f + cx2) * 0.03);
    var tmpy = cast(f32, cy2 * 0.03 - cy1 * 0.06);
    var dddx = cast(f32, ((cx1 - cx2) * 3.0f - time1 + time2) * 0.006);
    var dddy = cast(f32, (cy1 - cy2 + 0.33333333) * 0.018);
    f32 ddx = tmpx * 2.0f + dddx;
    f32 ddy = tmpy * 2.0f + dddy;
    var dx = cast(f32, (cx1 - time1) * 0.3 + tmpx + dddx * 0.16666667);
    var dy = cast(f32, cy1 * 0.3 + tmpy + dddy * 0.16666667);
    f32 x = time1 + dx;
    f32 y = dy;
    if value == 0.0f {
        curves[frame] = cast(f32, 2 + i);
    }
    for n = i + 18; i < n; i += 2 {
        curves[i] = x;
        curves[i + 1] = y;
        dx += ddx;
        dy += ddy;
        ddx += dddx;
        ddy += dddy;
        x += dx;
        y += dy;
    }
    ignore value1;
    ignore value2;
}

f32 _spDeformTimeline_getCurvePercent(spDeformTimeline* self, f32 time, i32 frame) {
    f32* curves = self.super.curves.items;
    f32* frames = self.super.super.frames.items;
    i32 n;
    var i = cast(i32, curves[frame]);
    i32 frameEntries = self.super.super.frameEntries;
    f32 x;
    f32 y;
    switch i {
        case 0: {
            {
                x = frames[frame];
                return (time - x) / (frames[frame + frameEntries] - x);
            }
        }
        case 1: {
            {
                return 0.0f;
            }
        }
        default: {
            {
            }
        }
    }
    i -= 2;
    if curves[i] > time {
        x = frames[frame];
        return curves[i + 1] * (time - x) / (curves[i] - x);
    }
    n = i + 18;
    for i += 2; i < n; i += 2 {
        if curves[i] >= time {
            x = curves[i - 2];
            y = curves[i - 1];
            return y + (time - x) / (curves[i] - x) * (curves[i + 1] - y);
        }
    }
    x = curves[n - 2];
    y = curves[n - 1];
    return y + (1.0f - y) * (time - x) / (frames[frame + frameEntries] - x);
}

void _spDeformTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    i32 frame;
    i32 i;
    i32 vertexCount;
    f32 percent;
    f32* prevVertices;
    f32* nextVertices;
    f32* frames;
    i32 framesCount;
    f32** frameVertices;
    f32* deformArray;
    var self = cast(spDeformTimeline*, timeline);
    spSlot* slot = skeleton.slots[self.slotIndex];
    if slot.bone.active == 0 {
        return;
    }
    if slot.attachment == null {
        return;
    }
    switch slot.attachment.type {
        case SP_ATTACHMENT_BOUNDING_BOX, SP_ATTACHMENT_CLIPPING, SP_ATTACHMENT_MESH, SP_ATTACHMENT_PATH: {
            {
                var vertexAttachment = cast(spVertexAttachment*, slot.attachment);
                if vertexAttachment.timelineAttachment != self.attachment {
                    return;
                }
                break case;
            }
        }
        default: {
            return;
        }
    }
    frames = self.super.super.frames.items;
    framesCount = self.super.super.frames.size;
    vertexCount = self.frameVerticesCount;
    if slot.deformCount < vertexCount {
        if slot.deformCapacity < vertexCount {
            _spFree(cast(void*, slot.deform));
            slot.deform = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * vertexCount), "extension.h", 83));
            slot.deformCapacity = vertexCount;
        }
    }
    if slot.deformCount == 0 {
        blend = SP_MIX_BLEND_SETUP;
    }
    frameVertices = self.frameVertices;
    deformArray = slot.deform;
    if time < frames[0] {
        var vertexAttachment = cast(spVertexAttachment*, slot.attachment);
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                slot.deformCount = 0;
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                if alpha == 1.0f {
                    slot.deformCount = 0;
                    return;
                }
                slot.deformCount = vertexCount;
                if vertexAttachment.bones == null {
                    f32* setupVertices = vertexAttachment.vertices;
                    for i = 0; i < vertexCount; i++ {
                        deformArray[i] += (setupVertices[i] - deformArray[i]) * alpha;
                    }
                } else {
                    alpha = 1.0f - alpha;
                    for i = 0; i < vertexCount; i++ {
                        deformArray[i] *= alpha;
                    }
                }
                fallthrough;
            }
            case SP_MIX_BLEND_REPLACE, SP_MIX_BLEND_ADD: {
            }
        }
        return;
    }
    slot.deformCount = vertexCount;
    if time >= frames[framesCount - 1] {
        f32* lastVertices = self.frameVertices[framesCount - 1];
        if alpha == 1.0f {
            if blend == SP_MIX_BLEND_ADD {
                var vertexAttachment = cast(spVertexAttachment*, slot.attachment);
                if vertexAttachment.bones == null {
                    f32* setupVertices = vertexAttachment.vertices;
                    for i = 0; i < vertexCount; i++ {
                        deformArray[i] += lastVertices[i] - setupVertices[i];
                    }
                } else {
                    for i = 0; i < vertexCount; i++ {
                        deformArray[i] += lastVertices[i];
                    }
                }
            } else {
                memcpy(deformArray, lastVertices, cast(u64, vertexCount * sizeof(f32)));
            }
        } else {
            spVertexAttachment* vertexAttachment;
            switch blend {
                case SP_MIX_BLEND_SETUP: {
                    vertexAttachment = cast(spVertexAttachment*, slot.attachment);
                    if vertexAttachment.bones == null {
                        f32* setupVertices = vertexAttachment.vertices;
                        for i = 0; i < vertexCount; i++ {
                            f32 setup = setupVertices[i];
                            deformArray[i] = setup + (lastVertices[i] - setup) * alpha;
                        }
                    } else {
                        for i = 0; i < vertexCount; i++ {
                            deformArray[i] = lastVertices[i] * alpha;
                        }
                    }
                }
                case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
                    for i = 0; i < vertexCount; i++ {
                        deformArray[i] += (lastVertices[i] - deformArray[i]) * alpha;
                    }
                }
                case SP_MIX_BLEND_ADD: {
                    vertexAttachment = cast(spVertexAttachment*, slot.attachment);
                    if vertexAttachment.bones == null {
                        f32* setupVertices = vertexAttachment.vertices;
                        for i = 0; i < vertexCount; i++ {
                            deformArray[i] += (lastVertices[i] - setupVertices[i]) * alpha;
                        }
                    } else {
                        for i = 0; i < vertexCount; i++ {
                            deformArray[i] += lastVertices[i] * alpha;
                        }
                    }
                }
            }
        }
        return;
    }
    frame = search(self.super.super.frames, time);
    percent = _spDeformTimeline_getCurvePercent(self, time, frame);
    prevVertices = frameVertices[frame];
    nextVertices = frameVertices[frame + 1];
    if alpha == 1.0f {
        if blend == SP_MIX_BLEND_ADD {
            var vertexAttachment = cast(spVertexAttachment*, slot.attachment);
            if vertexAttachment.bones == null {
                f32* setupVertices = vertexAttachment.vertices;
                for i = 0; i < vertexCount; i++ {
                    f32 prev = prevVertices[i];
                    deformArray[i] += prev + (nextVertices[i] - prev) * percent - setupVertices[i];
                }
            } else {
                for i = 0; i < vertexCount; i++ {
                    f32 prev = prevVertices[i];
                    deformArray[i] += prev + (nextVertices[i] - prev) * percent;
                }
            }
        } else {
            for i = 0; i < vertexCount; i++ {
                f32 prev = prevVertices[i];
                deformArray[i] = prev + (nextVertices[i] - prev) * percent;
            }
        }
    } else {
        spVertexAttachment* vertexAttachment;
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                vertexAttachment = cast(spVertexAttachment*, slot.attachment);
                if vertexAttachment.bones == null {
                    f32* setupVertices = vertexAttachment.vertices;
                    for i = 0; i < vertexCount; i++ {
                        f32 prev = prevVertices[i];
                        f32 setup = setupVertices[i];
                        deformArray[i] = setup + (prev + (nextVertices[i] - prev) * percent - setup) * alpha;
                    }
                } else {
                    for i = 0; i < vertexCount; i++ {
                        f32 prev = prevVertices[i];
                        deformArray[i] = (prev + (nextVertices[i] - prev) * percent) * alpha;
                    }
                }
            }
            case SP_MIX_BLEND_FIRST, SP_MIX_BLEND_REPLACE: {
                for i = 0; i < vertexCount; i++ {
                    f32 prev = prevVertices[i];
                    deformArray[i] += (prev + (nextVertices[i] - prev) * percent - deformArray[i]) * alpha;
                }
            }
            case SP_MIX_BLEND_ADD: {
                vertexAttachment = cast(spVertexAttachment*, slot.attachment);
                if vertexAttachment.bones == null {
                    f32* setupVertices = vertexAttachment.vertices;
                    for i = 0; i < vertexCount; i++ {
                        f32 prev = prevVertices[i];
                        deformArray[i] += (prev + (nextVertices[i] - prev) * percent - setupVertices[i]) * alpha;
                    }
                } else {
                    for i = 0; i < vertexCount; i++ {
                        f32 prev = prevVertices[i];
                        deformArray[i] += (prev + (nextVertices[i] - prev) * percent) * alpha;
                    }
                }
            }
        }
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

void _spDeformTimeline_dispose(spTimeline* timeline) {
    var self = cast(spDeformTimeline*, timeline);
    i32 i;
    for i = 0; i < self.super.super.frames.size; ++i {
        _spFree(cast(void*, self.frameVertices[i]));
    }
    _spFree(cast(void*, self.frameVertices));
    _spCurveTimeline_dispose(timeline);
}

spDeformTimeline* spDeformTimeline_create(i32 framesCount, i32 frameVerticesCount, i32 bezierCount, i32 slotIndex, spVertexAttachment* attachment) {
    var self = cast(spDeformTimeline*, _spCalloc(1, cast(u64, sizeof(spDeformTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_DEFORM) << 32 | cast(u64, (slotIndex << 16 | attachment.id) & 0xffffffff);
    _spCurveTimeline_init(&self.super, framesCount, 1, bezierCount, ids, 1, SP_TIMELINE_DEFORM, cast(fn(spTimeline*): void, _spDeformTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spDeformTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spDeformTimeline_setBezier));
    self.frameVertices = cast(f32**, _spCalloc(cast(u64, framesCount), cast(u64, sizeof(f32*)), "extension.h", 87));
    self.frameVerticesCount = frameVerticesCount;
    self.slotIndex = slotIndex;
    self.attachment = &attachment.super;
    return self;
}

void spDeformTimeline_setFrame(spDeformTimeline* self, i32 frame, f32 time, f32* vertices) {
    self.super.super.frames.items[frame] = time;
    _spFree(cast(void*, self.frameVertices[frame]));
    if vertices == null {
        self.frameVertices[frame] = null;
    } else {
        self.frameVertices[frame] = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * self.frameVerticesCount), "extension.h", 83));
        memcpy(self.frameVertices[frame], vertices, cast(u64, self.frameVerticesCount * sizeof(f32)));
    }
}
/**/
private { i32 SEQUENCE_ENTRIES = 3; }
private { i32 MODE = 1; }
private { i32 DELAY = 2; }

void _spSequenceTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spSequenceTimeline*, timeline);
    spSlot* slot = skeleton.slots[self.slotIndex];
    spAttachment* slotAttachment;
    f32* frames;
    i32 i;
    i32 modeAndIndex;
    i32 count;
    i32 index;
    i32 mode;
    f32 before;
    f32 delay;
    spSequence* sequence = null;
    if slot.bone.active == 0 {
        return;
    }
    slotAttachment = slot.attachment;
    if slotAttachment != self.attachment {
        if slotAttachment == null {
            return;
        }
        switch slotAttachment.type {
            case SP_ATTACHMENT_BOUNDING_BOX, SP_ATTACHMENT_CLIPPING, SP_ATTACHMENT_MESH, SP_ATTACHMENT_PATH: {
                {
                    var vertexAttachment = cast(spVertexAttachment*, slot.attachment);
                    if vertexAttachment.timelineAttachment != self.attachment {
                        return;
                    }
                    break case;
                }
            }
            default: {
                return;
            }
        }
    }
    if self.attachment.type == SP_ATTACHMENT_REGION {
        sequence = cast(spRegionAttachment*, self.attachment).sequence;
    }
    if self.attachment.type == SP_ATTACHMENT_MESH {
        sequence = cast(spMeshAttachment*, self.attachment).sequence;
    }
    if sequence == null {
        return;
    }
    if direction == SP_MIX_DIRECTION_OUT {
        if blend == SP_MIX_BLEND_SETUP {
            slot.sequenceIndex = -1;
        }
        return;
    }
    frames = self.super.frames.items;
    if time < frames[0] {
        if blend == SP_MIX_BLEND_SETUP || blend == SP_MIX_BLEND_FIRST {
            slot.sequenceIndex = -1;
        }
        return;
    }
    i = search2(self.super.frames, time, SEQUENCE_ENTRIES);
    before = frames[i];
    modeAndIndex = cast(i32, frames[i + MODE]);
    delay = frames[i + DELAY];
    index = modeAndIndex >> 4;
    count = sequence.regions.size;
    mode = modeAndIndex & 0xf;
    if mode != 0 {
        index += cast(i32, (time - before) / delay + 0.0001);
        switch mode {
            case 1: {
                index = count - 1 < index ? count - 1 : index;
            }
            case 2: {
                index %= count;
            }
            case 3: {
                {
                    i32 n = (count << 1) - 2;
                    index = n == 0 ? 0 : index % n;
                    if index >= count {
                        index = n - index;
                    }
                    break case;
                }
            }
            case 4: {
                index = count - 1 - index > 0 ? count - 1 - index : 0;
            }
            case 5: {
                index = count - 1 - index % count;
            }
            case 6: {
                {
                    i32 n = (count << 1) - 2;
                    index = n == 0 ? 0 : (index + count - 1) % n;
                    if index >= count {
                        index = n - index;
                    }
                }
            }
        }
    }
    slot.sequenceIndex = index;
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore alpha;
    ignore direction;
}

void _spSequenceTimeline_dispose(spTimeline* timeline) {
    ignore timeline;
}

spSequenceTimeline* spSequenceTimeline_create(i32 framesCount, i32 slotIndex, spAttachment* attachment) {
    i32 sequenceId = 0;
    var self = cast(spSequenceTimeline*, _spCalloc(1, cast(u64, sizeof(spSequenceTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    if attachment.type == SP_ATTACHMENT_REGION {
        sequenceId = cast(spRegionAttachment*, attachment).sequence.id;
    }
    if attachment.type == SP_ATTACHMENT_MESH {
        sequenceId = cast(spMeshAttachment*, attachment).sequence.id;
    }
    ids[0] = cast(spPropertyId, SP_PROPERTY_SEQUENCE) << 32 | cast(u64, (slotIndex << 16 | sequenceId) & 0xffffffff);
    _spTimeline_init(&self.super, framesCount, SEQUENCE_ENTRIES, ids, 1, SP_TIMELINE_SEQUENCE, cast(fn(spTimeline*): void, _spSequenceTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spSequenceTimeline_apply), null);
    self.slotIndex = slotIndex;
    self.attachment = attachment;
    return self;
}

void spSequenceTimeline_setFrame(spSequenceTimeline* self, i32 frame, f32 time, i32 mode, i32 index, f32 delay) {
    f32* frames = self.super.frames.items;
    frame *= SEQUENCE_ENTRIES;
    frames[frame] = time;
    frames[frame + MODE] = cast(f32, mode | index << 4);
    frames[frame + DELAY] = delay;
}

/**/
/** Fires events for frames > lastTime and <= time. */
void _spEventTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spEventTimeline*, timeline);
    f32* frames = self.super.frames.items;
    i32 framesCount = self.super.frames.size;
    i32 i;
    if firedEvents == null {
        return;
    }
    if lastTime > time {
        _spEventTimeline_apply(timeline, skeleton, lastTime, cast(f32, INT_MAX), firedEvents, eventsCount, alpha, blend, direction);
        lastTime = cast(f32, -1);
    } else if lastTime >= frames[framesCount - 1] {
        return;
    }
    if time < frames[0] {
        return;
    }
    if lastTime < frames[0] {
        i = 0;
    } else {
        f32 frameTime;
        i = search(self.super.frames, lastTime) + 1;
        frameTime = frames[i];
        while i > 0 {
            if frames[i - 1] != frameTime {
                break;
            }
            i--;
        }
    }
    for ; i < framesCount && time >= frames[i]; ++i {
        firedEvents[*eventsCount] = self.events[i];
        (*eventsCount)++;
    }
    ignore direction;
}

void _spEventTimeline_dispose(spTimeline* timeline) {
    var self = cast(spEventTimeline*, timeline);
    i32 i;
    for i = 0; i < self.super.frames.size; ++i {
        spEvent_dispose(self.events[i]);
    }
    _spFree(cast(void*, self.events));
}

spEventTimeline* spEventTimeline_create(i32 framesCount) {
    var self = cast(spEventTimeline*, _spCalloc(1, cast(u64, sizeof(spEventTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_EVENT) << 32;
    _spTimeline_init(&self.super, framesCount, 1, ids, 1, SP_TIMELINE_EVENT, cast(fn(spTimeline*): void, _spEventTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spEventTimeline_apply), null);
    self.events = cast(spEvent**, _spCalloc(cast(u64, framesCount), cast(u64, sizeof(spEvent*)), "extension.h", 87));
    return self;
}

void spEventTimeline_setFrame(spEventTimeline* self, i32 frame, spEvent* event) {
    self.super.frames.items[frame] = event.time;
    _spFree(cast(void*, self.events[frame]));
    self.events[frame] = event;
}

/**/
void _spDrawOrderTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    i32 i;
    i32* drawOrderToSetupIndex;
    var self = cast(spDrawOrderTimeline*, timeline);
    f32* frames = self.super.frames.items;
    if direction == SP_MIX_DIRECTION_OUT {
        if blend == SP_MIX_BLEND_SETUP {
            memcpy(skeleton.drawOrder, skeleton.slots, cast(u64, self.slotsCount * sizeof(spSlot*)));
        }
        return;
    }
    if time < frames[0] {
        if blend == SP_MIX_BLEND_SETUP || blend == SP_MIX_BLEND_FIRST {
            memcpy(skeleton.drawOrder, skeleton.slots, cast(u64, self.slotsCount * sizeof(spSlot*)));
        }
        return;
    }
    drawOrderToSetupIndex = self.drawOrders[search(self.super.frames, time)];
    if drawOrderToSetupIndex == null {
        memcpy(skeleton.drawOrder, skeleton.slots, cast(u64, self.slotsCount * sizeof(spSlot*)));
    } else {
        for i = 0; i < self.slotsCount; ++i {
            skeleton.drawOrder[i] = skeleton.slots[drawOrderToSetupIndex[i]];
        }
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore alpha;
}

void _spDrawOrderTimeline_dispose(spTimeline* timeline) {
    var self = cast(spDrawOrderTimeline*, timeline);
    i32 i;
    for i = 0; i < self.super.frames.size; ++i {
        _spFree(cast(void*, self.drawOrders[i]));
    }
    _spFree(cast(void*, self.drawOrders));
}

spDrawOrderTimeline* spDrawOrderTimeline_create(i32 framesCount, i32 slotsCount) {
    var self = cast(spDrawOrderTimeline*, _spCalloc(1, cast(u64, sizeof(spDrawOrderTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_DRAWORDER) << 32;
    _spTimeline_init(&self.super, framesCount, 1, ids, 1, SP_TIMELINE_DRAWORDER, cast(fn(spTimeline*): void, _spDrawOrderTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spDrawOrderTimeline_apply), null);
    self.drawOrders = cast(i32**, _spCalloc(cast(u64, framesCount), cast(u64, sizeof(i32*)), "extension.h", 87));
    self.slotsCount = slotsCount;
    return self;
}

void spDrawOrderTimeline_setFrame(spDrawOrderTimeline* self, i32 frame, f32 time, i32* drawOrder) {
    self.super.frames.items[frame] = time;
    _spFree(cast(void*, self.drawOrders[frame]));
    if drawOrder == null {
        self.drawOrders[frame] = null;
    } else {
        self.drawOrders[frame] = cast(i32*, _spMalloc(cast(u64, sizeof(i32) * self.slotsCount), "extension.h", 83));
        memcpy(self.drawOrders[frame], drawOrder, cast(u64, self.slotsCount * sizeof(i32)));
    }
}

/**/
void _spInheritTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spInheritTimeline*, timeline);
    spBone* bone = skeleton.bones[self.boneIndex];
    f32* frames = self.super.frames.items;
    if bone.active == 0 {
        return;
    }
    if direction == SP_MIX_DIRECTION_OUT {
        if blend == SP_MIX_BLEND_SETUP {
            bone.inherit = bone.data.inherit;
        }
        return;
    }
    if time < frames[0] {
        if blend == SP_MIX_BLEND_SETUP || blend == SP_MIX_BLEND_FIRST {
            bone.inherit = bone.data.inherit;
        }
        return;
    }
    i32 idx = search2(self.super.frames, time, 2) + 1;
    bone.inherit = cast(spInherit, frames[idx]);
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore alpha;
    ignore direction;
}

void _spInheritTimeline_dispose(spTimeline* timeline) {
    ignore timeline;
}

spInheritTimeline* spInheritTimeline_create(i32 framesCount, i32 boneIndex) {
    var self = cast(spInheritTimeline*, _spCalloc(1, cast(u64, sizeof(spInheritTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_INHERIT) << 32;
    _spTimeline_init(&self.super, framesCount, 2, ids, 1, SP_TIMELINE_INHERIT, cast(fn(spTimeline*): void, _spInheritTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spInheritTimeline_apply), null);
    self.boneIndex = boneIndex;
    return self;
}

void spInheritTimeline_setFrame(spInheritTimeline* self, i32 frame, f32 time, spInherit inherit) {
    frame *= 2;
    self.super.frames.items[frame] = time;
    self.super.frames.items[frame + 1] = cast(f32, inherit);
}
/**/
private { i32 IKCONSTRAINT_ENTRIES = 6; }
private { i32 IKCONSTRAINT_MIX = 1; }
private { i32 IKCONSTRAINT_SOFTNESS = 2; }
private { i32 IKCONSTRAINT_BEND_DIRECTION = 3; }
private { i32 IKCONSTRAINT_COMPRESS = 4; }
private { i32 IKCONSTRAINT_STRETCH = 5; }

void _spIkConstraintTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    i32 i;
    i32 curveType;
    f32 mix;
    f32 softness;
    f32 t;
    spIkConstraint* constraint;
    var self = cast(spIkConstraintTimeline*, timeline);
    f32* frames = self.super.super.frames.items;
    f32* curves = self.super.curves.items;
    constraint = skeleton.ikConstraints[self.ikConstraintIndex];
    if constraint.active == 0 {
        return;
    }
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                constraint.mix = constraint.data.mix;
                constraint.softness = constraint.data.softness;
                constraint.bendDirection = constraint.data.bendDirection;
                constraint.compress = constraint.data.compress;
                constraint.stretch = constraint.data.stretch;
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                constraint.mix += (constraint.data.mix - constraint.mix) * alpha;
                constraint.softness += (constraint.data.softness - constraint.softness) * alpha;
                constraint.bendDirection = constraint.data.bendDirection;
                constraint.compress = constraint.data.compress;
                constraint.stretch = constraint.data.stretch;
                return;
            }
            default: {
                return;
            }
        }
    }
    i = search2(self.super.super.frames, time, IKCONSTRAINT_ENTRIES);
    curveType = cast(i32, curves[i / IKCONSTRAINT_ENTRIES]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                mix = frames[i + IKCONSTRAINT_MIX];
                softness = frames[i + IKCONSTRAINT_SOFTNESS];
                t = (time - before) / (frames[i + IKCONSTRAINT_ENTRIES] - before);
                mix += (frames[i + IKCONSTRAINT_ENTRIES + IKCONSTRAINT_MIX] - mix) * t;
                softness += (frames[i + IKCONSTRAINT_ENTRIES + IKCONSTRAINT_SOFTNESS] - softness) * t;
                break case;
            }
        }
        case 1: {
            {
                mix = frames[i + IKCONSTRAINT_MIX];
                softness = frames[i + IKCONSTRAINT_SOFTNESS];
                break case;
            }
        }
        default: {
            {
                mix = _spCurveTimeline_getBezierValue(&self.super, time, i, IKCONSTRAINT_MIX, curveType - 2);
                softness = _spCurveTimeline_getBezierValue(&self.super, time, i, IKCONSTRAINT_SOFTNESS, curveType + 18 - 2);
            }
        }
    }
    if blend == SP_MIX_BLEND_SETUP {
        constraint.mix = constraint.data.mix + (mix - constraint.data.mix) * alpha;
        constraint.softness = constraint.data.softness + (softness - constraint.data.softness) * alpha;
        if direction == SP_MIX_DIRECTION_OUT {
            constraint.bendDirection = constraint.data.bendDirection;
            constraint.compress = constraint.data.compress;
            constraint.stretch = constraint.data.stretch;
        } else {
            constraint.bendDirection = cast(i32, frames[i + IKCONSTRAINT_BEND_DIRECTION]);
            constraint.compress = frames[i + IKCONSTRAINT_COMPRESS] != 0.0f;
            constraint.stretch = frames[i + IKCONSTRAINT_STRETCH] != 0.0f;
        }
    } else {
        constraint.mix += (mix - constraint.mix) * alpha;
        constraint.softness += (softness - constraint.softness) * alpha;
        if direction == SP_MIX_DIRECTION_IN {
            constraint.bendDirection = cast(i32, frames[i + IKCONSTRAINT_BEND_DIRECTION]);
            constraint.compress = frames[i + IKCONSTRAINT_COMPRESS] != 0.0f;
            constraint.stretch = frames[i + IKCONSTRAINT_STRETCH] != 0.0f;
        }
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
}

spIkConstraintTimeline* spIkConstraintTimeline_create(i32 framesCount, i32 bezierCount, i32 ikConstraintIndex) {
    var timeline = cast(spIkConstraintTimeline*, _spCalloc(1, cast(u64, sizeof(spIkConstraintTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_IKCONSTRAINT) << 32 | cast(u64, ikConstraintIndex);
    _spCurveTimeline_init(&timeline.super, framesCount, IKCONSTRAINT_ENTRIES, bezierCount, ids, 1, SP_TIMELINE_IKCONSTRAINT, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spIkConstraintTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.ikConstraintIndex = ikConstraintIndex;
    return timeline;
}

void spIkConstraintTimeline_setFrame(spIkConstraintTimeline* self, i32 frame, f32 time, f32 mix, f32 softness, i32 bendDirection, i32 compress, i32 stretch) {
    f32* frames = self.super.super.frames.items;
    frame *= IKCONSTRAINT_ENTRIES;
    frames[frame] = time;
    frames[frame + IKCONSTRAINT_MIX] = mix;
    frames[frame + IKCONSTRAINT_SOFTNESS] = softness;
    frames[frame + IKCONSTRAINT_BEND_DIRECTION] = cast(f32, bendDirection);
    frames[frame + IKCONSTRAINT_COMPRESS] = cast(f32, compress != 0 ? 1 : 0);
    frames[frame + IKCONSTRAINT_STRETCH] = cast(f32, stretch != 0 ? 1 : 0);
}
/**/
private {
i32 TRANSFORMCONSTRAINT_ENTRIES = 7;
i32 TRANSFORMCONSTRAINT_ROTATE = 1;
i32 TRANSFORMCONSTRAINT_X = 2;
i32 TRANSFORMCONSTRAINT_Y = 3;
i32 TRANSFORMCONSTRAINT_SCALEX = 4;
i32 TRANSFORMCONSTRAINT_SCALEY = 5;
i32 TRANSFORMCONSTRAINT_SHEARY = 6;
}

void _spTransformConstraintTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    i32 i;
    i32 curveType;
    f32 rotate;
    f32 x;
    f32 y;
    f32 scaleX;
    f32 scaleY;
    f32 shearY;
    f32 t;
    spTransformConstraint* constraint;
    var self = cast(spTransformConstraintTimeline*, timeline);
    f32* frames;
    f32* curves;
    spTransformConstraintData* data;
    constraint = skeleton.transformConstraints[self.transformConstraintIndex];
    if constraint.active == 0 {
        return;
    }
    frames = self.super.super.frames.items;
    curves = self.super.curves.items;
    data = constraint.data;
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                constraint.mixRotate = data.mixRotate;
                constraint.mixX = data.mixX;
                constraint.mixY = data.mixY;
                constraint.mixScaleX = data.mixScaleX;
                constraint.mixScaleY = data.mixScaleY;
                constraint.mixShearY = data.mixShearY;
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                constraint.mixRotate += (data.mixRotate - constraint.mixRotate) * alpha;
                constraint.mixX += (data.mixX - constraint.mixX) * alpha;
                constraint.mixY += (data.mixY - constraint.mixY) * alpha;
                constraint.mixScaleX += (data.mixScaleX - constraint.mixScaleX) * alpha;
                constraint.mixScaleY += (data.mixScaleY - constraint.mixScaleY) * alpha;
                constraint.mixShearY += (data.mixShearY - constraint.mixShearY) * alpha;
                return;
            }
            default: {
                return;
            }
        }
    }
    i = search2(self.super.super.frames, time, TRANSFORMCONSTRAINT_ENTRIES);
    curveType = cast(i32, curves[i / TRANSFORMCONSTRAINT_ENTRIES]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                rotate = frames[i + TRANSFORMCONSTRAINT_ROTATE];
                x = frames[i + TRANSFORMCONSTRAINT_X];
                y = frames[i + TRANSFORMCONSTRAINT_Y];
                scaleX = frames[i + TRANSFORMCONSTRAINT_SCALEX];
                scaleY = frames[i + TRANSFORMCONSTRAINT_SCALEY];
                shearY = frames[i + TRANSFORMCONSTRAINT_SHEARY];
                t = (time - before) / (frames[i + TRANSFORMCONSTRAINT_ENTRIES] - before);
                rotate += (frames[i + TRANSFORMCONSTRAINT_ENTRIES + TRANSFORMCONSTRAINT_ROTATE] - rotate) * t;
                x += (frames[i + TRANSFORMCONSTRAINT_ENTRIES + TRANSFORMCONSTRAINT_X] - x) * t;
                y += (frames[i + TRANSFORMCONSTRAINT_ENTRIES + TRANSFORMCONSTRAINT_Y] - y) * t;
                scaleX += (frames[i + TRANSFORMCONSTRAINT_ENTRIES + TRANSFORMCONSTRAINT_SCALEX] - scaleX) * t;
                scaleY += (frames[i + TRANSFORMCONSTRAINT_ENTRIES + TRANSFORMCONSTRAINT_SCALEY] - scaleY) * t;
                shearY += (frames[i + TRANSFORMCONSTRAINT_ENTRIES + TRANSFORMCONSTRAINT_SHEARY] - shearY) * t;
                break case;
            }
        }
        case 1: {
            {
                rotate = frames[i + TRANSFORMCONSTRAINT_ROTATE];
                x = frames[i + TRANSFORMCONSTRAINT_X];
                y = frames[i + TRANSFORMCONSTRAINT_Y];
                scaleX = frames[i + TRANSFORMCONSTRAINT_SCALEX];
                scaleY = frames[i + TRANSFORMCONSTRAINT_SCALEY];
                shearY = frames[i + TRANSFORMCONSTRAINT_SHEARY];
                break case;
            }
        }
        default: {
            {
                rotate = _spCurveTimeline_getBezierValue(&self.super, time, i, TRANSFORMCONSTRAINT_ROTATE, curveType - 2);
                x = _spCurveTimeline_getBezierValue(&self.super, time, i, TRANSFORMCONSTRAINT_X, curveType + 18 - 2);
                y = _spCurveTimeline_getBezierValue(&self.super, time, i, TRANSFORMCONSTRAINT_Y, curveType + 18 * 2 - 2);
                scaleX = _spCurveTimeline_getBezierValue(&self.super, time, i, TRANSFORMCONSTRAINT_SCALEX, curveType + 18 * 3 - 2);
                scaleY = _spCurveTimeline_getBezierValue(&self.super, time, i, TRANSFORMCONSTRAINT_SCALEY, curveType + 18 * 4 - 2);
                shearY = _spCurveTimeline_getBezierValue(&self.super, time, i, TRANSFORMCONSTRAINT_SHEARY, curveType + 18 * 5 - 2);
            }
        }
    }
    if blend == SP_MIX_BLEND_SETUP {
        constraint.mixRotate = data.mixRotate + (rotate - data.mixRotate) * alpha;
        constraint.mixX = data.mixX + (x - data.mixX) * alpha;
        constraint.mixY = data.mixY + (y - data.mixY) * alpha;
        constraint.mixScaleX = data.mixScaleX + (scaleX - data.mixScaleX) * alpha;
        constraint.mixScaleY = data.mixScaleY + (scaleY - data.mixScaleY) * alpha;
        constraint.mixShearY = data.mixShearY + (shearY - data.mixShearY) * alpha;
    } else {
        constraint.mixRotate += (rotate - constraint.mixRotate) * alpha;
        constraint.mixX += (x - constraint.mixX) * alpha;
        constraint.mixY += (y - constraint.mixY) * alpha;
        constraint.mixScaleX += (scaleX - constraint.mixScaleX) * alpha;
        constraint.mixScaleY += (scaleY - constraint.mixScaleY) * alpha;
        constraint.mixShearY += (shearY - constraint.mixShearY) * alpha;
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spTransformConstraintTimeline* spTransformConstraintTimeline_create(i32 framesCount, i32 bezierCount, i32 transformConstraintIndex) {
    var timeline = cast(spTransformConstraintTimeline*, _spCalloc(1, cast(u64, sizeof(spTransformConstraintTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_TRANSFORMCONSTRAINT) << 32 | cast(u64, transformConstraintIndex);
    _spCurveTimeline_init(&timeline.super, framesCount, TRANSFORMCONSTRAINT_ENTRIES, bezierCount, ids, 1, SP_TIMELINE_TRANSFORMCONSTRAINT, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spTransformConstraintTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.transformConstraintIndex = transformConstraintIndex;
    return timeline;
}

void spTransformConstraintTimeline_setFrame(spTransformConstraintTimeline* self, i32 frame, f32 time, f32 mixRotate, f32 mixX, f32 mixY, f32 mixScaleX, f32 mixScaleY, f32 mixShearY) {
    f32* frames = self.super.super.frames.items;
    frame *= TRANSFORMCONSTRAINT_ENTRIES;
    frames[frame] = time;
    frames[frame + TRANSFORMCONSTRAINT_ROTATE] = mixRotate;
    frames[frame + TRANSFORMCONSTRAINT_X] = mixX;
    frames[frame + TRANSFORMCONSTRAINT_Y] = mixY;
    frames[frame + TRANSFORMCONSTRAINT_SCALEX] = mixScaleX;
    frames[frame + TRANSFORMCONSTRAINT_SCALEY] = mixScaleY;
    frames[frame + TRANSFORMCONSTRAINT_SHEARY] = mixShearY;
}
/**/
private {
i32 PATHCONSTRAINTPOSITION_ENTRIES = 2;
i32 PATHCONSTRAINTPOSITION_VALUE = 1;
}

void _spPathConstraintPositionTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spPathConstraintPositionTimeline*, timeline);
    spPathConstraint* constraint = skeleton.pathConstraints[self.pathConstraintIndex];
    if constraint.active != 0 {
        constraint.position = spCurveTimeline1_getAbsoluteValue(&self.super, time, alpha, blend, constraint.position, constraint.data.position);
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spPathConstraintPositionTimeline* spPathConstraintPositionTimeline_create(i32 framesCount, i32 bezierCount, i32 pathConstraintIndex) {
    var timeline = cast(spPathConstraintPositionTimeline*, _spCalloc(1, cast(u64, sizeof(spPathConstraintPositionTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_PATHCONSTRAINT_POSITION) << 32 | cast(u64, pathConstraintIndex);
    _spCurveTimeline_init(&timeline.super, framesCount, PATHCONSTRAINTPOSITION_ENTRIES, bezierCount, ids, 1, SP_TIMELINE_PATHCONSTRAINTPOSITION, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spPathConstraintPositionTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.pathConstraintIndex = pathConstraintIndex;
    return timeline;
}

void spPathConstraintPositionTimeline_setFrame(spPathConstraintPositionTimeline* self, i32 frame, f32 time, f32 value) {
    f32* frames = self.super.super.frames.items;
    frame *= PATHCONSTRAINTPOSITION_ENTRIES;
    frames[frame] = time;
    frames[frame + PATHCONSTRAINTPOSITION_VALUE] = value;
}
/**/
private {
i32 PATHCONSTRAINTSPACING_ENTRIES = 2;
i32 PATHCONSTRAINTSPACING_VALUE = 1;
}

void _spPathConstraintSpacingTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spPathConstraintSpacingTimeline*, timeline);
    spPathConstraint* constraint = skeleton.pathConstraints[self.pathConstraintIndex];
    if constraint.active != 0 {
        constraint.spacing = spCurveTimeline1_getAbsoluteValue(&self.super, time, alpha, blend, constraint.spacing, constraint.data.spacing);
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spPathConstraintSpacingTimeline* spPathConstraintSpacingTimeline_create(i32 framesCount, i32 bezierCount, i32 pathConstraintIndex) {
    var timeline = cast(spPathConstraintSpacingTimeline*, _spCalloc(1, cast(u64, sizeof(spPathConstraintSpacingTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_PATHCONSTRAINT_SPACING) << 32 | cast(u64, pathConstraintIndex);
    _spCurveTimeline_init(&timeline.super, framesCount, PATHCONSTRAINTSPACING_ENTRIES, bezierCount, ids, 1, SP_TIMELINE_PATHCONSTRAINTSPACING, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spPathConstraintSpacingTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.pathConstraintIndex = pathConstraintIndex;
    return timeline;
}

void spPathConstraintSpacingTimeline_setFrame(spPathConstraintSpacingTimeline* self, i32 frame, f32 time, f32 value) {
    f32* frames = self.super.super.frames.items;
    frame *= PATHCONSTRAINTSPACING_ENTRIES;
    frames[frame] = time;
    frames[frame + PATHCONSTRAINTSPACING_VALUE] = value;
}
/**/
private {
i32 PATHCONSTRAINTMIX_ENTRIES = 4;
i32 PATHCONSTRAINTMIX_ROTATE = 1;
i32 PATHCONSTRAINTMIX_X = 2;
i32 PATHCONSTRAINTMIX_Y = 3;
}

void _spPathConstraintMixTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    i32 i;
    i32 curveType;
    f32 rotate;
    f32 x;
    f32 y;
    f32 t;
    spPathConstraint* constraint;
    var self = cast(spPathConstraintMixTimeline*, timeline);
    f32* frames;
    f32* curves;
    constraint = skeleton.pathConstraints[self.pathConstraintIndex];
    if constraint.active == 0 {
        return;
    }
    frames = self.super.super.frames.items;
    curves = self.super.curves.items;
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                constraint.mixRotate = constraint.data.mixRotate;
                constraint.mixX = constraint.data.mixX;
                constraint.mixY = constraint.data.mixY;
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                constraint.mixRotate += (constraint.data.mixRotate - constraint.mixRotate) * alpha;
                constraint.mixX += (constraint.data.mixX - constraint.mixX) * alpha;
                constraint.mixY += (constraint.data.mixY - constraint.mixY) * alpha;
                fallthrough;
            }
            default: {
                {
                }
            }
        }
        return;
    }
    i = search2(self.super.super.frames, time, PATHCONSTRAINTMIX_ENTRIES);
    curveType = cast(i32, curves[i >> 2]);
    switch curveType {
        case 0: {
            {
                f32 before = frames[i];
                rotate = frames[i + PATHCONSTRAINTMIX_ROTATE];
                x = frames[i + PATHCONSTRAINTMIX_X];
                y = frames[i + PATHCONSTRAINTMIX_Y];
                t = (time - before) / (frames[i + PATHCONSTRAINTMIX_ENTRIES] - before);
                rotate += (frames[i + PATHCONSTRAINTMIX_ENTRIES + PATHCONSTRAINTMIX_ROTATE] - rotate) * t;
                x += (frames[i + PATHCONSTRAINTMIX_ENTRIES + PATHCONSTRAINTMIX_X] - x) * t;
                y += (frames[i + PATHCONSTRAINTMIX_ENTRIES + PATHCONSTRAINTMIX_Y] - y) * t;
                break case;
            }
        }
        case 1: {
            {
                rotate = frames[i + PATHCONSTRAINTMIX_ROTATE];
                x = frames[i + PATHCONSTRAINTMIX_X];
                y = frames[i + PATHCONSTRAINTMIX_Y];
                break case;
            }
        }
        default: {
            {
                rotate = _spCurveTimeline_getBezierValue(&self.super, time, i, PATHCONSTRAINTMIX_ROTATE, curveType - 2);
                x = _spCurveTimeline_getBezierValue(&self.super, time, i, PATHCONSTRAINTMIX_X, curveType + 18 - 2);
                y = _spCurveTimeline_getBezierValue(&self.super, time, i, PATHCONSTRAINTMIX_Y, curveType + 18 * 2 - 2);
            }
        }
    }
    if blend == SP_MIX_BLEND_SETUP {
        spPathConstraintData* data = constraint.data;
        constraint.mixRotate = data.mixRotate + (rotate - data.mixRotate) * alpha;
        constraint.mixX = data.mixX + (x - data.mixX) * alpha;
        constraint.mixY = data.mixY + (y - data.mixY) * alpha;
    } else {
        constraint.mixRotate += (rotate - constraint.mixRotate) * alpha;
        constraint.mixX += (x - constraint.mixX) * alpha;
        constraint.mixY += (y - constraint.mixY) * alpha;
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spPathConstraintMixTimeline* spPathConstraintMixTimeline_create(i32 framesCount, i32 bezierCount, i32 pathConstraintIndex) {
    var timeline = cast(spPathConstraintMixTimeline*, _spCalloc(1, cast(u64, sizeof(spPathConstraintMixTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_PATHCONSTRAINT_MIX) << 32 | cast(u64, pathConstraintIndex);
    _spCurveTimeline_init(&timeline.super, framesCount, PATHCONSTRAINTMIX_ENTRIES, bezierCount, ids, 1, SP_TIMELINE_PATHCONSTRAINTMIX, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spPathConstraintMixTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.pathConstraintIndex = pathConstraintIndex;
    return timeline;
}

void spPathConstraintMixTimeline_setFrame(spPathConstraintMixTimeline* self, i32 frame, f32 time, f32 mixRotate, f32 mixX, f32 mixY) {
    f32* frames = self.super.super.frames.items;
    frame *= PATHCONSTRAINTMIX_ENTRIES;
    frames[frame] = time;
    frames[frame + PATHCONSTRAINTMIX_ROTATE] = mixRotate;
    frames[frame + PATHCONSTRAINTMIX_X] = mixX;
    frames[frame + PATHCONSTRAINTMIX_Y] = mixY;
}

/**/
i32 _spPhysicsConstraintTimeline_global(spPhysicsConstraintData* data, spTimelineType type) {
    switch type {
        case SP_TIMELINE_PHYSICSCONSTRAINT_INERTIA: {
            return data.inertiaGlobal;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_STRENGTH: {
            return data.strengthGlobal;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_DAMPING: {
            return data.dampingGlobal;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_MASS: {
            return data.massGlobal;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_WIND: {
            return data.windGlobal;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_GRAVITY: {
            return data.gravityGlobal;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_MIX: {
            return data.mixGlobal;
        }
        default: {
            return 0;
        }
    }
}

void _spPhysicsConstraintTimeline_set(spPhysicsConstraint* constraint, spTimelineType type, f32 value) {
    switch type {
        case SP_TIMELINE_PHYSICSCONSTRAINT_INERTIA: {
            constraint.inertia = value;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_STRENGTH: {
            constraint.strength = value;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_DAMPING: {
            constraint.damping = value;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_MASS: {
            constraint.massInverse = value;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_WIND: {
            constraint.wind = value;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_GRAVITY: {
            constraint.gravity = value;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_MIX: {
            constraint.mix = value;
        }
        default: {
        }
    }
}

f32 _spPhysicsConstraintTimeline_get(spPhysicsConstraint* constraint, spTimelineType type) {
    switch type {
        case SP_TIMELINE_PHYSICSCONSTRAINT_INERTIA: {
            return constraint.inertia;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_STRENGTH: {
            return constraint.strength;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_DAMPING: {
            return constraint.damping;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_MASS: {
            return constraint.massInverse;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_WIND: {
            return constraint.wind;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_GRAVITY: {
            return constraint.gravity;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_MIX: {
            return constraint.mix;
        }
        default: {
            return 0.0f;
        }
    }
}

f32 _spPhysicsConstraintTimeline_setup(spPhysicsConstraint* constraint, spTimelineType type) {
    switch type {
        case SP_TIMELINE_PHYSICSCONSTRAINT_INERTIA: {
            return constraint.data.inertia;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_STRENGTH: {
            return constraint.data.strength;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_DAMPING: {
            return constraint.data.damping;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_MASS: {
            return constraint.data.massInverse;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_WIND: {
            return constraint.data.wind;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_GRAVITY: {
            return constraint.data.gravity;
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_MIX: {
            return constraint.data.mix;
        }
        default: {
            return 0.0f;
        }
    }
}

void _spPhysicsConstraintTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spPhysicsConstraintTimeline*, timeline);
    spTimelineType type = self.super.super.type;
    f32* frames = self.super.super.frames.items;
    if self.physicsConstraintIndex == -1 {
        f32 value = time >= frames[0] ? spCurveTimeline1_getCurveValue(&self.super, time) : 0.0f;
        spPhysicsConstraint** physicsConstraints = skeleton.physicsConstraints;
        for i32 i = 0; i < skeleton.physicsConstraintsCount; i++ {
            spPhysicsConstraint* constraint = physicsConstraints[i];
            if constraint.active && _spPhysicsConstraintTimeline_global(constraint.data, type) {
                _spPhysicsConstraintTimeline_set(constraint, type, spCurveTimeline1_getAbsoluteValue2(&self.super, time, alpha, blend, _spPhysicsConstraintTimeline_get(constraint, type), _spPhysicsConstraintTimeline_setup(constraint, type), value));
            }
        }
    } else {
        spPhysicsConstraint* constraint = skeleton.physicsConstraints[self.physicsConstraintIndex];
        if constraint.active != 0 {
            _spPhysicsConstraintTimeline_set(constraint, type, spCurveTimeline1_getAbsoluteValue(&self.super, time, alpha, blend, _spPhysicsConstraintTimeline_get(constraint, type), _spPhysicsConstraintTimeline_setup(constraint, type)));
        }
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore direction;
}

spPhysicsConstraintTimeline* spPhysicsConstraintTimeline_create(i32 frameCount, i32 bezierCount, i32 physicsConstraintIndex, spTimelineType type) {
    var timeline = cast(spPhysicsConstraintTimeline*, _spCalloc(1, cast(u64, sizeof(spPhysicsConstraintTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    spPropertyId id;
    switch type {
        case SP_TIMELINE_PHYSICSCONSTRAINT_INERTIA: {
            id = cast(u64, SP_PROPERTY_PHYSICSCONSTRAINT_INERTIA);
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_STRENGTH: {
            id = cast(u64, SP_PROPERTY_PHYSICSCONSTRAINT_STRENGTH);
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_DAMPING: {
            id = cast(u64, SP_PROPERTY_PHYSICSCONSTRAINT_DAMPING);
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_MASS: {
            id = cast(u64, SP_PROPERTY_PHYSICSCONSTRAINT_MASS);
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_WIND: {
            id = cast(u64, SP_PROPERTY_PHYSICSCONSTRAINT_WIND);
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_GRAVITY: {
            id = cast(u64, SP_PROPERTY_PHYSICSCONSTRAINT_GRAVITY);
        }
        case SP_TIMELINE_PHYSICSCONSTRAINT_MIX: {
            id = cast(u64, SP_PROPERTY_PHYSICSCONSTRAINT_MIX);
        }
        default: {
            id = cast(u64, SP_PROPERTY_PHYSICSCONSTRAINT_INERTIA);
        }
    }
    ids[0] = cast(spPropertyId, id) << 32 | cast(u64, physicsConstraintIndex);
    _spCurveTimeline_init(&timeline.super, frameCount, 2, bezierCount, ids, 1, type, cast(fn(spTimeline*): void, _spCurveTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spPhysicsConstraintTimeline_apply), cast(fn(spTimeline*, i32, i32, f32, f32, f32, f32, f32, f32, f32, f32, f32): void, _spCurveTimeline_setBezier));
    timeline.physicsConstraintIndex = physicsConstraintIndex;
    return timeline;
}

void spPhysicsConstraintTimeline_setFrame(spPhysicsConstraintTimeline* self, i32 frame, f32 time, f32 value) {
    spCurveTimeline1_setFrame(&self.super, frame, time, value);
}

/**/
void _spPhysicsConstraintResetTimeline_apply(spTimeline* timeline, spSkeleton* skeleton, f32 lastTime, f32 time, spEvent** firedEvents, i32* eventsCount, f32 alpha, spMixBlend blend, spMixDirection direction) {
    var self = cast(spPhysicsConstraintResetTimeline*, timeline);
    spPhysicsConstraint* constraint = null;
    if self.physicsConstraintIndex != -1 {
        constraint = skeleton.physicsConstraints[self.physicsConstraintIndex];
        if constraint.active == 0 {
            return;
        }
    }
    f32* frames = self.super.frames.items;
    if lastTime > time {
        _spPhysicsConstraintResetTimeline_apply(&self.super, skeleton, lastTime, cast(f32, INT_MAX), null, null, alpha, blend, direction);
        lastTime = cast(f32, -1);
    } else if lastTime >= frames[self.super.frameCount - 1] {
        return;
    }
    if time < frames[0] {
        return;
    }
    if lastTime < frames[0] || time >= frames[search(self.super.frames, lastTime) + 1] {
        if constraint != null {
            spPhysicsConstraint_reset(constraint);
        } else {
            spPhysicsConstraint** physicsConstraints = skeleton.physicsConstraints;
            for i32 i = 0; i < skeleton.physicsConstraintsCount; i++ {
                constraint = physicsConstraints[i];
                if constraint.active != 0 {
                    spPhysicsConstraint_reset(constraint);
                }
            }
        }
    }
    ignore lastTime;
    ignore firedEvents;
    ignore eventsCount;
    ignore alpha;
    ignore direction;
}

void _spPhysicsConstraintResetTimeline_dispose(spTimeline* timeline) {
    ignore timeline;
}

spPhysicsConstraintResetTimeline* spPhysicsConstraintResetTimeline_create(i32 framesCount, i32 physicsConstraintIndex) {
    var self = cast(spPhysicsConstraintResetTimeline*, _spCalloc(1, cast(u64, sizeof(spPhysicsConstraintResetTimeline)), "extension.h", 87));
    noinit spPropertyId[1] ids;
    ids[0] = cast(spPropertyId, SP_PROPERTY_PHYSICSCONSTRAINT_RESET) << 32;
    _spTimeline_init(&self.super, framesCount, 1, ids, 1, SP_TIMELINE_PHYSICSCONSTRAINT_RESET, cast(fn(spTimeline*): void, _spPhysicsConstraintResetTimeline_dispose), cast(fn(spTimeline*, spSkeleton*, f32, f32, spEvent**, i32*, f32, spMixBlend, spMixDirection): void, _spPhysicsConstraintResetTimeline_apply), null);
    self.physicsConstraintIndex = physicsConstraintIndex;
    return self;
}

void spPhysicsConstraintResetTimeline_setFrame(spPhysicsConstraintResetTimeline* self, i32 frame, f32 time) {
    self.super.frames.items[frame] = time;
}

spTrackEntryArray* spTrackEntryArray_create(i32 initialCapacity) {
    var array = cast(spTrackEntryArray*, _spCalloc(1, cast(u64, sizeof(spTrackEntryArray)), "extension.h", 77));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spTrackEntry**, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spTrackEntry*)), "extension.h", 77));
    return array;
}

void spTrackEntryArray_dispose(spTrackEntryArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spTrackEntryArray_clear(spTrackEntryArray* self) {
    self.size = 0;
}

spTrackEntryArray* spTrackEntryArray_setSize(spTrackEntryArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spTrackEntry**, _spRealloc(self.items, cast(u64, sizeof(spTrackEntry*) * self.capacity)));
    }
    return self;
}

void spTrackEntryArray_ensureCapacity(spTrackEntryArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spTrackEntry**, _spRealloc(self.items, cast(u64, sizeof(spTrackEntry*) * self.capacity)));
}

void spTrackEntryArray_add(spTrackEntryArray* self, spTrackEntry* value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spTrackEntry**, _spRealloc(self.items, cast(u64, sizeof(spTrackEntry*) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spTrackEntryArray_addAll(spTrackEntryArray* self, spTrackEntryArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spTrackEntryArray_add(self, other.items[i]);
    }
}

void spTrackEntryArray_addAllValues(spTrackEntryArray* self, spTrackEntry** values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spTrackEntryArray_add(self, values[i]);
    }
}

void spTrackEntryArray_removeAt(spTrackEntryArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spTrackEntry*) * (self.size - index)));
}

i32 spTrackEntryArray_contains(spTrackEntryArray* self, spTrackEntry* value) {
    spTrackEntry** items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spTrackEntry* spTrackEntryArray_pop(spTrackEntryArray* self) {
    spTrackEntry* item = self.items[--self.size];
    return item;
}

spTrackEntry* spTrackEntryArray_peek(spTrackEntryArray* self) {
    return self.items[self.size - 1];
}
private { spAnimation* SP_EMPTY_ANIMATION = null; }

void spAnimationState_disposeStatics() {
    if SP_EMPTY_ANIMATION != null {
        spAnimation_dispose(SP_EMPTY_ANIMATION);
    }
    SP_EMPTY_ANIMATION = null;
}

_spEventQueue* _spEventQueue_create(_spAnimationState* state) {
    var self = cast(_spEventQueue*, _spCalloc(1, cast(u64, sizeof(_spEventQueue)), "extension.h", 77));
    self.state = state;
    self.objectsCount = 0;
    self.objectsCapacity = 16;
    self.objects = cast(_spEventQueueItem*, _spCalloc(cast(u64, self.objectsCapacity), cast(u64, sizeof(_spEventQueueItem)), "extension.h", 77));
    self.drainDisabled = 0;
    return self;
}

void _spEventQueue_free(_spEventQueue* self) {
    _spFree(cast(void*, self.objects));
    _spFree(cast(void*, self));
}

void _spEventQueue_ensureCapacity(_spEventQueue* self, i32 newElements) {
    if self.objectsCount + newElements > self.objectsCapacity {
        _spEventQueueItem* newObjects;
        self.objectsCapacity <<= 1;
        newObjects = cast(_spEventQueueItem*, _spCalloc(cast(u64, self.objectsCapacity), cast(u64, sizeof(_spEventQueueItem)), "extension.h", 77));
        memcpy(newObjects, self.objects, cast(u64, sizeof(_spEventQueueItem) * self.objectsCount));
        _spFree(cast(void*, self.objects));
        self.objects = newObjects;
    }
}

void _spEventQueue_addType(_spEventQueue* self, spEventType type) {
    _spEventQueue_ensureCapacity(self, 1);
    self.objects[self.objectsCount++].type = type;
}

void _spEventQueue_addEntry(_spEventQueue* self, spTrackEntry* entry) {
    _spEventQueue_ensureCapacity(self, 1);
    self.objects[self.objectsCount++].entry = entry;
}

void _spEventQueue_addEvent(_spEventQueue* self, spEvent* event) {
    _spEventQueue_ensureCapacity(self, 1);
    self.objects[self.objectsCount++].event = event;
}

void _spEventQueue_start(_spEventQueue* self, spTrackEntry* entry) {
    _spEventQueue_addType(self, SP_ANIMATION_START);
    _spEventQueue_addEntry(self, entry);
    self.state.animationsChanged = 1;
}

void _spEventQueue_interrupt(_spEventQueue* self, spTrackEntry* entry) {
    _spEventQueue_addType(self, SP_ANIMATION_INTERRUPT);
    _spEventQueue_addEntry(self, entry);
}

void _spEventQueue_end(_spEventQueue* self, spTrackEntry* entry) {
    _spEventQueue_addType(self, SP_ANIMATION_END);
    _spEventQueue_addEntry(self, entry);
    self.state.animationsChanged = 1;
}

void _spEventQueue_dispose(_spEventQueue* self, spTrackEntry* entry) {
    _spEventQueue_addType(self, SP_ANIMATION_DISPOSE);
    _spEventQueue_addEntry(self, entry);
}

void _spEventQueue_complete(_spEventQueue* self, spTrackEntry* entry) {
    _spEventQueue_addType(self, SP_ANIMATION_COMPLETE);
    _spEventQueue_addEntry(self, entry);
}

void _spEventQueue_event(_spEventQueue* self, spTrackEntry* entry, spEvent* event) {
    _spEventQueue_addType(self, SP_ANIMATION_EVENT);
    _spEventQueue_addEntry(self, entry);
    _spEventQueue_addEvent(self, event);
}

void _spEventQueue_clear(_spEventQueue* self) {
    self.objectsCount = 0;
}

void _spEventQueue_drain(_spEventQueue* self) {
    i32 i;
    if self.drainDisabled != 0 {
        return;
    }
    self.drainDisabled = 1;
    for i = 0; i < self.objectsCount; i += 2 {
        var type = cast(spEventType, self.objects[i].type);
        spTrackEntry* entry = self.objects[i + 1].entry;
        spEvent* event;
        switch type {
            case SP_ANIMATION_START, SP_ANIMATION_INTERRUPT, SP_ANIMATION_COMPLETE: {
                if entry.listener != null {
                    entry.listener(&self.state.super, type, entry, null);
                }
                if self.state.super.listener != null {
                    self.state.super.listener(&self.state.super, type, entry, null);
                }
            }
            case SP_ANIMATION_END: {
                if entry.listener != null {
                    entry.listener(&self.state.super, type, entry, null);
                }
                if self.state.super.listener != null {
                    self.state.super.listener(&self.state.super, type, entry, null);
                }
                fallthrough;
            }
            case SP_ANIMATION_DISPOSE: {
                if entry.listener != null {
                    entry.listener(&self.state.super, SP_ANIMATION_DISPOSE, entry, null);
                }
                if self.state.super.listener != null {
                    self.state.super.listener(&self.state.super, SP_ANIMATION_DISPOSE, entry, null);
                }
                _spAnimationState_disposeTrackEntry(entry);
            }
            case SP_ANIMATION_EVENT: {
                event = self.objects[i + 2].event;
                if entry.listener != null {
                    entry.listener(&self.state.super, type, entry, event);
                }
                if self.state.super.listener != null {
                    self.state.super.listener(&self.state.super, type, entry, event);
                }
                i++;
            }
        }
    }
    _spEventQueue_clear(self);
    self.drainDisabled = 0;
}

/* These two functions are needed in the UE4 runtime, see #1037 */
void _spAnimationState_enableQueue(spAnimationState* self) {
    var internal = cast(_spAnimationState*, self);
    internal.queue.drainDisabled = 0;
}

void _spAnimationState_disableQueue(spAnimationState* self) {
    var internal = cast(_spAnimationState*, self);
    internal.queue.drainDisabled = 1;
}

void _spAnimationState_disposeTrackEntry(spTrackEntry* entry) {
    spIntArray_dispose(entry.timelineMode);
    spTrackEntryArray_dispose(entry.timelineHoldMix);
    _spFree(cast(void*, entry.timelinesRotation));
    _spFree(cast(void*, entry));
}

void _spAnimationState_disposeTrackEntries(spAnimationState* state, spTrackEntry* entry) {
    while entry != null {
        spTrackEntry* next = entry.next;
        spTrackEntry* from_var = entry.mixingFrom;  // renamed from: from
        while from_var != null {
            spTrackEntry* nextFrom = from_var.mixingFrom;
            if entry.listener != null {
                entry.listener(state, SP_ANIMATION_DISPOSE, from_var, null);
            }
            if state.listener != null {
                state.listener(state, SP_ANIMATION_DISPOSE, from_var, null);
            }
            _spAnimationState_disposeTrackEntry(from_var);
            from_var = nextFrom;
        }
        if entry.listener != null {
            entry.listener(state, SP_ANIMATION_DISPOSE, entry, null);
        }
        if state.listener != null {
            state.listener(state, SP_ANIMATION_DISPOSE, entry, null);
        }
        _spAnimationState_disposeTrackEntry(entry);
        entry = next;
    }
}

spAnimationState* spAnimationState_create(spAnimationStateData* data) {
    _spAnimationState* internal;
    spAnimationState* self;
    if SP_EMPTY_ANIMATION == null {
        SP_EMPTY_ANIMATION = cast(spAnimation*, 1);
        SP_EMPTY_ANIMATION = spAnimation_create("<empty>", null, 0.0f);
    }
    internal = cast(_spAnimationState*, _spCalloc(1, cast(u64, sizeof(_spAnimationState)), "extension.h", 77));
    self = &internal.super;
    self.data = data;
    self.timeScale = 1.0f;
    internal.queue = _spEventQueue_create(internal);
    internal.events = cast(spEvent**, _spCalloc(128, cast(u64, sizeof(spEvent*)), "extension.h", 77));
    internal.propertyIDs = cast(spPropertyId*, _spCalloc(128, cast(u64, sizeof(spPropertyId)), "extension.h", 77));
    internal.propertyIDsCapacity = 128;
    return self;
}

void spAnimationState_dispose(spAnimationState* self) {
    i32 i;
    var internal = cast(_spAnimationState*, self);
    for i = 0; i < self.tracksCount; i++ {
        _spAnimationState_disposeTrackEntries(self, self.tracks[i]);
    }
    _spFree(cast(void*, self.tracks));
    _spEventQueue_free(internal.queue);
    _spFree(cast(void*, internal.events));
    _spFree(cast(void*, internal.propertyIDs));
    _spFree(cast(void*, internal));
}

void spAnimationState_update(spAnimationState* self, f32 delta) {
    i32 i;
    i32 n;
    var internal = cast(_spAnimationState*, self);
    delta *= self.timeScale;
    {
        i = 0;
        for n = self.tracksCount; i < n; i++ {
            f32 currentDelta;
            spTrackEntry* current = self.tracks[i];
            spTrackEntry* next;
            if current == null {
                continue;
            }
            current.animationLast = current.nextAnimationLast;
            current.trackLast = current.nextTrackLast;
            currentDelta = delta * current.timeScale;
            if current.delay > 0.0f {
                current.delay -= currentDelta;
                if current.delay > 0.0f {
                    continue;
                }
                currentDelta = -current.delay;
                current.delay = 0.0f;
            }
            next = current.next;
            if next != null {
                f32 nextTime = current.trackLast - next.delay;
                if nextTime >= 0.0f {
                    next.delay = 0.0f;
                    next.trackTime += cast(f32, current.timeScale == 0.0f ? 0.0f : (nextTime / current.timeScale + delta) * next.timeScale);
                    current.trackTime += currentDelta;
                    _spAnimationState_setCurrent(self, i, next, 1);
                    while next.mixingFrom != null {
                        next.mixTime += delta;
                        next = next.mixingFrom;
                    }
                    continue;
                }
            } else {
                if current.trackLast >= current.trackEnd && current.mixingFrom == null {
                    self.tracks[i] = null;
                    _spEventQueue_end(internal.queue, current);
                    spAnimationState_clearNext(self, current);
                    continue;
                }
            }
            if current.mixingFrom != null && _spAnimationState_updateMixingFrom(self, current, delta) {
                spTrackEntry* from_var = current.mixingFrom;  // renamed from: from
                current.mixingFrom = null;
                if from_var != null {
                    from_var.mixingTo = null;
                }
                while from_var != null {
                    _spEventQueue_end(internal.queue, from_var);
                    from_var = from_var.mixingFrom;
                }
            }
            current.trackTime += currentDelta;
        }
    }
    _spEventQueue_drain(internal.queue);
}

i32 _spAnimationState_updateMixingFrom(spAnimationState* self, spTrackEntry* to, f32 delta) {
    spTrackEntry* from_var = to.mixingFrom;  // renamed from: from
    i32 finished;
    var internal = cast(_spAnimationState*, self);
    if from_var == null {
        return -1;
    }
    finished = _spAnimationState_updateMixingFrom(self, from_var, delta);
    from_var.animationLast = from_var.nextAnimationLast;
    from_var.trackLast = from_var.nextTrackLast;
    if to.nextTrackLast != -1.0f {
        i32 discard = to.mixTime == 0.0f && from_var.mixTime == 0.0f;
        if to.mixTime >= to.mixDuration || discard {
            if from_var.totalAlpha == 0.0f || to.mixDuration == 0.0f || discard {
                to.mixingFrom = from_var.mixingFrom;
                if from_var.mixingFrom != null {
                    from_var.mixingFrom.mixingTo = to;
                }
                to.interruptAlpha = from_var.interruptAlpha;
                _spEventQueue_end(internal.queue, from_var);
            }
            return finished;
        }
    }
    from_var.trackTime += delta * from_var.timeScale;
    to.mixTime += delta;
    return 0;
}

i32 spAnimationState_apply(spAnimationState* self, spSkeleton* skeleton) {
    var internal = cast(_spAnimationState*, self);
    spTrackEntry* current;
    i32 i;
    i32 ii;
    i32 n;
    f32 animationLast;
    f32 animationTime;
    i32 timelineCount;
    spTimeline** timelines;
    i32 firstFrame;
    i32 shortestRotation;
    f32* timelinesRotation;
    spTimeline* timeline;
    i32 applied = 0;
    spMixBlend blend;
    spMixBlend timelineBlend;
    i32 setupState = 0;
    spSlot** slots = null;
    spSlot* slot = null;
    u8* attachmentName = null;
    spEvent** applyEvents = null;
    f32 applyTime;
    if internal.animationsChanged != 0 {
        _spAnimationState_animationsChanged(self);
    }
    {
        i = 0;
        for n = self.tracksCount; i < n; i++ {
            f32 alpha;
            current = self.tracks[i];
            if !current || current.delay > 0.0f {
                continue;
            }
            applied = -1;
            blend = i == 0 ? SP_MIX_BLEND_FIRST : current.mixBlend;
            alpha = current.alpha;
            if current.mixingFrom != null {
                alpha *= _spAnimationState_applyMixingFrom(self, current, skeleton, blend);
            } else if current.trackTime >= current.trackEnd && current.next == null {
                alpha = 0.0f;
            }
            i32 attachments = alpha >= current.alphaAttachmentThreshold;
            animationLast = current.animationLast;
            animationTime = spTrackEntry_getAnimationTime(current);
            timelineCount = current.animation.timelines.size;
            applyEvents = internal.events;
            applyTime = animationTime;
            if current.reverse != 0 {
                applyTime = current.animation.duration - applyTime;
                applyEvents = null;
            }
            timelines = current.animation.timelines.items;
            if i == 0 && alpha == 1.0f || blend == SP_MIX_BLEND_ADD {
                for ii = 0; ii < timelineCount; ii++ {
                    timeline = timelines[ii];
                    if timeline.type == SP_TIMELINE_ATTACHMENT {
                        _spAnimationState_applyAttachmentTimeline(self, timeline, skeleton, applyTime, blend, attachments);
                    } else {
                        spTimeline_apply(timelines[ii], skeleton, animationLast, applyTime, applyEvents, &internal.eventsCount, alpha, blend, SP_MIX_DIRECTION_IN);
                    }
                }
            } else {
                spIntArray* timelineMode = current.timelineMode;
                shortestRotation = current.shortestRotation;
                firstFrame = !shortestRotation && current.timelinesRotationCount != timelineCount << 1;
                if firstFrame != 0 {
                    _spAnimationState_resizeTimelinesRotation(current, timelineCount << 1);
                }
                timelinesRotation = current.timelinesRotation;
                for ii = 0; ii < timelineCount; ii++ {
                    timeline = timelines[ii];
                    timelineBlend = timelineMode.items[ii] == 0 ? blend : SP_MIX_BLEND_SETUP;
                    if !shortestRotation && timeline.type == SP_TIMELINE_ROTATE {
                        _spAnimationState_applyRotateTimeline(self, timeline, skeleton, applyTime, alpha, timelineBlend, timelinesRotation, ii << 1, firstFrame);
                    } else if timeline.type == SP_TIMELINE_ATTACHMENT {
                        _spAnimationState_applyAttachmentTimeline(self, timeline, skeleton, applyTime, timelineBlend, attachments);
                    } else {
                        spTimeline_apply(timeline, skeleton, animationLast, applyTime, applyEvents, &internal.eventsCount, alpha, timelineBlend, SP_MIX_DIRECTION_IN);
                    }
                }
            }
            _spAnimationState_queueEvents(self, current, animationTime);
            internal.eventsCount = 0;
            current.nextAnimationLast = animationTime;
            current.nextTrackLast = current.trackTime;
        }
    }
    setupState = self.unkeyedState + 1;
    slots = skeleton.slots;
    {
        i = 0;
        for n = skeleton.slotsCount; i < n; i++ {
            slot = slots[i];
            if slot.attachmentState == setupState {
                attachmentName = slot.data.attachmentName;
                spSlot_setAttachment(slot, attachmentName == null ? null : spSkeleton_getAttachmentForSlotIndex(skeleton, slot.data.index, attachmentName));
            }
        }
    }
    self.unkeyedState += 2;
    _spEventQueue_drain(internal.queue);
    return applied;
}

f32 _spAnimationState_applyMixingFrom(spAnimationState* self, spTrackEntry* to, spSkeleton* skeleton, spMixBlend blend) {
    var internal = cast(_spAnimationState*, self);
    f32 mix;
    spEvent** events;
    i32 attachments;
    i32 drawOrder;
    f32 animationLast;
    f32 animationTime;
    i32 timelineCount;
    spTimeline** timelines;
    spIntArray* timelineMode;
    spTrackEntryArray* timelineHoldMix;
    spMixBlend timelineBlend;
    f32 alphaHold;
    f32 alphaMix;
    f32 alpha;
    i32 firstFrame;
    i32 shortestRotation;
    f32* timelinesRotation;
    i32 i;
    spTrackEntry* holdMix;
    f32 applyTime;
    spTrackEntry* from_var = to.mixingFrom;  // renamed from: from
    if from_var.mixingFrom != null {
        _spAnimationState_applyMixingFrom(self, from_var, skeleton, blend);
    }
    if to.mixDuration == 0.0f {
        mix = 1.0f;
        if blend == SP_MIX_BLEND_FIRST {
            blend = SP_MIX_BLEND_SETUP;
        }
    } else {
        mix = to.mixTime / to.mixDuration;
        if mix > 1.0f {
            mix = 1.0f;
        }
        if blend != SP_MIX_BLEND_FIRST {
            blend = from_var.mixBlend;
        }
    }
    attachments = mix < from_var.mixAttachmentThreshold;
    drawOrder = mix < from_var.mixDrawOrderThreshold;
    timelineCount = from_var.animation.timelines.size;
    timelines = from_var.animation.timelines.items;
    alphaHold = from_var.alpha * to.interruptAlpha;
    alphaMix = alphaHold * (1.0f - mix);
    animationLast = from_var.animationLast;
    animationTime = spTrackEntry_getAnimationTime(from_var);
    applyTime = animationTime;
    events = null;
    if from_var.reverse != 0 {
        applyTime = from_var.animation.duration - applyTime;
    } else {
        if mix < from_var.eventThreshold {
            events = internal.events;
        }
    }
    if blend == SP_MIX_BLEND_ADD {
        for i = 0; i < timelineCount; i++ {
            spTimeline* timeline = timelines[i];
            spTimeline_apply(timeline, skeleton, animationLast, applyTime, events, &internal.eventsCount, alphaMix, blend, SP_MIX_DIRECTION_OUT);
        }
    } else {
        timelineMode = from_var.timelineMode;
        timelineHoldMix = from_var.timelineHoldMix;
        shortestRotation = from_var.shortestRotation;
        firstFrame = !shortestRotation && from_var.timelinesRotationCount != timelineCount << 1;
        if firstFrame != 0 {
            _spAnimationState_resizeTimelinesRotation(from_var, timelineCount << 1);
        }
        timelinesRotation = from_var.timelinesRotation;
        from_var.totalAlpha = 0.0f;
        for i = 0; i < timelineCount; i++ {
            spMixDirection direction = SP_MIX_DIRECTION_OUT;
            spTimeline* timeline = timelines[i];
            switch timelineMode.items[i] {
                case 0: {
                    if !drawOrder && timeline.type == SP_TIMELINE_DRAWORDER {
                        continue;
                    }
                    timelineBlend = blend;
                    alpha = alphaMix;
                }
                case 1: {
                    timelineBlend = SP_MIX_BLEND_SETUP;
                    alpha = alphaMix;
                }
                case 2: {
                    timelineBlend = blend;
                    alpha = alphaHold;
                }
                case 3: {
                    timelineBlend = SP_MIX_BLEND_SETUP;
                    alpha = alphaHold;
                }
                default: {
                    timelineBlend = SP_MIX_BLEND_SETUP;
                    holdMix = timelineHoldMix.items[i];
                    alpha = alphaHold * cast(f32, 0.0f > 1.0f - holdMix.mixTime / holdMix.mixDuration ? 0.0f : 1.0f - holdMix.mixTime / holdMix.mixDuration);
                }
            }
            from_var.totalAlpha += alpha;
            if !shortestRotation && timeline.type == SP_TIMELINE_ROTATE {
                _spAnimationState_applyRotateTimeline(self, timeline, skeleton, applyTime, alpha, timelineBlend, timelinesRotation, i << 1, firstFrame);
            } else if timeline.type == SP_TIMELINE_ATTACHMENT {
                _spAnimationState_applyAttachmentTimeline(self, timeline, skeleton, applyTime, timelineBlend, cast(i32, attachments && alpha >= from_var.alphaAttachmentThreshold));
            } else {
                if drawOrder && timeline.type == SP_TIMELINE_DRAWORDER && timelineBlend == SP_MIX_BLEND_SETUP {
                    direction = SP_MIX_DIRECTION_IN;
                }
                spTimeline_apply(timeline, skeleton, animationLast, applyTime, events, &internal.eventsCount, alpha, timelineBlend, direction);
            }
        }
    }
    if to.mixDuration > 0.0f {
        _spAnimationState_queueEvents(self, from_var, animationTime);
    }
    internal.eventsCount = 0;
    from_var.nextAnimationLast = animationTime;
    from_var.nextTrackLast = from_var.trackTime;
    return mix;
}

private {
void _spAnimationState_setAttachment(spAnimationState* self, spSkeleton* skeleton, spSlot* slot, u8* attachmentName, i32 attachments) {
    spSlot_setAttachment(slot, attachmentName == null ? null : spSkeleton_getAttachmentForSlotIndex(skeleton, slot.data.index, attachmentName));
    if attachments != 0 {
        slot.attachmentState = self.unkeyedState + 2;
    }
}

/* @param target After the first and before the last entry. */
i32 binarySearch1(f32* values, i32 valuesLength, f32 target) {
    i32 i;
    for i = 1; i < valuesLength; i++ {
        if values[i] > target {
            return i - 1;
        }
    }
    return valuesLength - 1;
}
}

void _spAnimationState_applyAttachmentTimeline(spAnimationState* self, spTimeline* timeline, spSkeleton* skeleton, f32 time, spMixBlend blend, i32 attachments) {
    spAttachmentTimeline* attachmentTimeline;
    spSlot* slot;
    f32* frames;
    attachmentTimeline = cast(spAttachmentTimeline*, timeline);
    slot = skeleton.slots[attachmentTimeline.slotIndex];
    if slot.bone.active == 0 {
        return;
    }
    frames = attachmentTimeline.super.frames.items;
    if time < frames[0] {
        if blend == SP_MIX_BLEND_SETUP || blend == SP_MIX_BLEND_FIRST {
            _spAnimationState_setAttachment(self, skeleton, slot, slot.data.attachmentName, attachments);
        }
    } else {
        _spAnimationState_setAttachment(self, skeleton, slot, attachmentTimeline.attachmentNames[binarySearch1(frames, attachmentTimeline.super.frames.size, time)], attachments);
    }
    if slot.attachmentState <= self.unkeyedState {
        slot.attachmentState = self.unkeyedState + 1;
    }
}

void _spAnimationState_applyRotateTimeline(spAnimationState* self, spTimeline* timeline, spSkeleton* skeleton, f32 time, f32 alpha, spMixBlend blend, f32* timelinesRotation, i32 i, i32 firstFrame) {
    spRotateTimeline* rotateTimeline;
    f32* frames;
    spBone* bone;
    f32 r1;
    f32 r2;
    f32 total;
    f32 diff;
    i32 current;
    i32 dir;
    ignore self;
    if firstFrame != 0 {
        timelinesRotation[i] = 0.0f;
    }
    if alpha == 1.0f {
        spTimeline_apply(timeline, skeleton, 0.0f, time, null, null, 1.0f, blend, SP_MIX_DIRECTION_IN);
        return;
    }
    rotateTimeline = cast(spRotateTimeline*, timeline);
    frames = rotateTimeline.super.super.frames.items;
    bone = skeleton.bones[rotateTimeline.boneIndex];
    if bone.active == 0 {
        return;
    }
    if time < frames[0] {
        switch blend {
            case SP_MIX_BLEND_SETUP: {
                bone.rotation = bone.data.rotation;
                fallthrough;
            }
            default: {
                return;
            }
            case SP_MIX_BLEND_FIRST: {
                r1 = bone.rotation;
                r2 = bone.data.rotation;
            }
        }
    } else {
        r1 = blend == SP_MIX_BLEND_SETUP ? bone.data.rotation : bone.rotation;
        r2 = bone.data.rotation + spCurveTimeline1_getCurveValue(&rotateTimeline.super, time);
    }
    diff = r2 - r1;
    diff -= cast(f32, ceil(diff / 360.0f - 0.5)) * 360.0f;
    if diff == 0.0f {
        total = timelinesRotation[i];
    } else {
        f32 lastTotal;
        f32 lastDiff;
        f32 loops;
        if firstFrame != 0 {
            lastTotal = 0.0f;
            lastDiff = diff;
        } else {
            lastTotal = timelinesRotation[i];
            lastDiff = timelinesRotation[i + 1];
        }
        loops = lastTotal - fmodf(lastTotal, 360.0f);
        total = diff + loops;
        current = diff >= 0.0f;
        dir = lastTotal >= 0.0f;
        if (lastDiff < 0.0f ? -lastDiff : lastDiff) <= 90 && (lastDiff < 0.0f ? -1.0f : lastDiff > 0.0f ? 1.0f : 0.0f) != (diff < 0.0f ? -1.0f : diff > 0.0f ? 1.0f : 0.0f) {
            if (lastTotal - loops < 0.0f ? -(lastTotal - loops) : lastTotal - loops) > 180 {
                total += 360.0f * (lastTotal < 0.0f ? -1.0f : lastTotal > 0.0f ? 1.0f : 0.0f);
                dir = current;
            } else if loops != 0.0f {
                total -= 360.0f * (lastTotal < 0.0f ? -1.0f : lastTotal > 0.0f ? 1.0f : 0.0f);
            } else {
                dir = current;
            }
        }
        if dir != current {
            total += 360.0f * (lastTotal < 0.0f ? -1.0f : lastTotal > 0.0f ? 1.0f : 0.0f);
        }
        timelinesRotation[i] = total;
    }
    timelinesRotation[i + 1] = diff;
    bone.rotation = r1 + total * alpha;
}

void _spAnimationState_queueEvents(spAnimationState* self, spTrackEntry* entry, f32 animationTime) {
    spEvent** events;
    spEvent* event;
    var internal = cast(_spAnimationState*, self);
    i32 i;
    i32 n;
    i32 complete;
    f32 animationStart = entry.animationStart;
    f32 animationEnd = entry.animationEnd;
    f32 duration = animationEnd - animationStart;
    f32 trackLastWrapped = fmodf(entry.trackLast, duration);
    events = internal.events;
    {
        i = 0;
        for n = internal.eventsCount; i < n; i++ {
            event = events[i];
            if event.time < trackLastWrapped {
                break;
            }
            if event.time > animationEnd {
                continue;
            }
            _spEventQueue_event(internal.queue, entry, event);
        }
    }
    if entry.loop != 0 {
        if duration == 0.0f {
            complete = -1;
        } else {
            var cycles = cast(i32, entry.trackTime / duration);
            complete = cycles > 0 && cycles > cast(i32, entry.trackLast / duration);
        }
    } else {
        complete = animationTime >= animationEnd && entry.animationLast < animationEnd;
    }
    if complete != 0 {
        _spEventQueue_complete(internal.queue, entry);
    }
    for ; i < n; i++ {
        event = events[i];
        if event.time < animationStart {
            continue;
        }
        _spEventQueue_event(internal.queue, entry, event);
    }
}

void spAnimationState_clearTracks(spAnimationState* self) {
    var internal = cast(_spAnimationState*, self);
    i32 i;
    i32 n;
    i32 oldDrainDisabled;
    oldDrainDisabled = internal.queue.drainDisabled;
    internal.queue.drainDisabled = 1;
    {
        i = 0;
        for n = self.tracksCount; i < n; i++ {
            spAnimationState_clearTrack(self, i);
        }
    }
    self.tracksCount = 0;
    internal.queue.drainDisabled = oldDrainDisabled;
    _spEventQueue_drain(internal.queue);
}

void spAnimationState_clearTrack(spAnimationState* self, i32 trackIndex) {
    spTrackEntry* current;
    spTrackEntry* entry;
    spTrackEntry* from_var;  // renamed from: from
    var internal = cast(_spAnimationState*, self);
    if trackIndex >= self.tracksCount {
        return;
    }
    current = self.tracks[trackIndex];
    if current == null {
        return;
    }
    _spEventQueue_end(internal.queue, current);
    spAnimationState_clearNext(self, current);
    entry = current;
    while 1 != 0 {
        from_var = entry.mixingFrom;
        if from_var == null {
            break;
        }
        _spEventQueue_end(internal.queue, from_var);
        entry.mixingFrom = null;
        entry.mixingTo = null;
        entry = from_var;
    }
    self.tracks[current.trackIndex] = null;
    _spEventQueue_drain(internal.queue);
}

void _spAnimationState_setCurrent(spAnimationState* self, i32 index, spTrackEntry* current, i32 interrupt) {
    var internal = cast(_spAnimationState*, self);
    spTrackEntry* from_var = _spAnimationState_expandToIndex(self, index);  // renamed from: from
    self.tracks[index] = current;
    current.previous = null;
    if from_var != null {
        if interrupt != 0 {
            _spEventQueue_interrupt(internal.queue, from_var);
        }
        current.mixingFrom = from_var;
        from_var.mixingTo = current;
        current.mixTime = 0.0f;
        if from_var.mixingFrom != null && from_var.mixDuration > 0.0f {
            current.interruptAlpha *= cast(f32, 1.0f < from_var.mixTime / from_var.mixDuration ? 1.0f : from_var.mixTime / from_var.mixDuration);
        }
        from_var.timelinesRotationCount = 0;
    }
    _spEventQueue_start(internal.queue, current);
}

/** Set the current animation. Any queued animations are cleared. */
spTrackEntry* spAnimationState_setAnimationByName(spAnimationState* self, i32 trackIndex, u8* animationName, i32 loop) {
    spAnimation* animation = spSkeletonData_findAnimation(self.data.skeletonData, animationName);
    return spAnimationState_setAnimation(self, trackIndex, animation, loop);
}

spTrackEntry* spAnimationState_setAnimation(spAnimationState* self, i32 trackIndex, spAnimation* animation, i32 loop) {
    spTrackEntry* entry;
    var internal = cast(_spAnimationState*, self);
    i32 interrupt = 1;
    spTrackEntry* current = _spAnimationState_expandToIndex(self, trackIndex);
    if current != null {
        if current.nextTrackLast == -1.0f {
            self.tracks[trackIndex] = current.mixingFrom;
            _spEventQueue_interrupt(internal.queue, current);
            _spEventQueue_end(internal.queue, current);
            spAnimationState_clearNext(self, current);
            current = current.mixingFrom;
            interrupt = 0;
        } else {
            spAnimationState_clearNext(self, current);
        }
    }
    entry = _spAnimationState_trackEntry(self, trackIndex, animation, loop, current);
    _spAnimationState_setCurrent(self, trackIndex, entry, interrupt);
    _spEventQueue_drain(internal.queue);
    return entry;
}

/** Adds an animation to be played delay seconds after the current or last queued animation, taking into account any mix
 * duration. */
spTrackEntry* spAnimationState_addAnimationByName(spAnimationState* self, i32 trackIndex, u8* animationName, i32 loop, f32 delay) {
    spAnimation* animation = spSkeletonData_findAnimation(self.data.skeletonData, animationName);
    return spAnimationState_addAnimation(self, trackIndex, animation, loop, delay);
}

spTrackEntry* spAnimationState_addAnimation(spAnimationState* self, i32 trackIndex, spAnimation* animation, i32 loop, f32 delay) {
    spTrackEntry* entry;
    var internal = cast(_spAnimationState*, self);
    spTrackEntry* last = _spAnimationState_expandToIndex(self, trackIndex);
    if last != null {
        while last.next != null {
            last = last.next;
        }
    }
    entry = _spAnimationState_trackEntry(self, trackIndex, animation, loop, last);
    if last == null {
        _spAnimationState_setCurrent(self, trackIndex, entry, 1);
        _spEventQueue_drain(internal.queue);
    } else {
        last.next = entry;
        entry.previous = last;
        if delay <= 0.0f {
            delay += spTrackEntry_getTrackComplete(last) - entry.mixDuration;
        }
    }
    entry.delay = delay;
    return entry;
}

spTrackEntry* spAnimationState_setEmptyAnimation(spAnimationState* self, i32 trackIndex, f32 mixDuration) {
    spTrackEntry* entry = spAnimationState_setAnimation(self, trackIndex, SP_EMPTY_ANIMATION, 0);
    entry.mixDuration = mixDuration;
    entry.trackEnd = mixDuration;
    return entry;
}

spTrackEntry* spAnimationState_addEmptyAnimation(spAnimationState* self, i32 trackIndex, f32 mixDuration, f32 delay) {
    spTrackEntry* entry = spAnimationState_addAnimation(self, trackIndex, SP_EMPTY_ANIMATION, 0, delay);
    if delay <= 0.0f {
        entry.delay += entry.mixDuration - mixDuration;
    }
    entry.mixDuration = mixDuration;
    entry.trackEnd = mixDuration;
    return entry;
}

void spAnimationState_setEmptyAnimations(spAnimationState* self, f32 mixDuration) {
    i32 i;
    i32 n;
    i32 oldDrainDisabled;
    spTrackEntry* current;
    var internal = cast(_spAnimationState*, self);
    oldDrainDisabled = internal.queue.drainDisabled;
    internal.queue.drainDisabled = 1;
    {
        i = 0;
        for n = self.tracksCount; i < n; i++ {
            current = self.tracks[i];
            if current != null {
                spAnimationState_setEmptyAnimation(self, current.trackIndex, mixDuration);
            }
        }
    }
    internal.queue.drainDisabled = oldDrainDisabled;
    _spEventQueue_drain(internal.queue);
}

spTrackEntry* _spAnimationState_expandToIndex(spAnimationState* self, i32 index) {
    spTrackEntry** newTracks;
    if index < self.tracksCount {
        return self.tracks[index];
    }
    newTracks = cast(spTrackEntry**, _spCalloc(cast(u64, index + 1), cast(u64, sizeof(spTrackEntry*)), "extension.h", 77));
    memcpy(newTracks, self.tracks, cast(u64, self.tracksCount * sizeof(spTrackEntry*)));
    _spFree(cast(void*, self.tracks));
    self.tracks = newTracks;
    self.tracksCount = index + 1;
    return null;
}

spTrackEntry* _spAnimationState_trackEntry(spAnimationState* self, i32 trackIndex, spAnimation* animation, i32 loop, spTrackEntry* last) {
    var entry = cast(spTrackEntry*, _spCalloc(1, cast(u64, sizeof(spTrackEntry)), "extension.h", 77));
    entry.trackIndex = trackIndex;
    entry.animation = animation;
    entry.loop = loop;
    entry.holdPrevious = 0;
    entry.reverse = 0;
    entry.shortestRotation = 0;
    entry.previous = null;
    entry.next = null;
    entry.eventThreshold = 0.0f;
    entry.mixAttachmentThreshold = 0.0f;
    entry.alphaAttachmentThreshold = 0.0f;
    entry.mixDrawOrderThreshold = 0.0f;
    entry.animationStart = 0.0f;
    entry.animationEnd = animation.duration;
    entry.animationLast = cast(f32, -1);
    entry.nextAnimationLast = cast(f32, -1);
    entry.delay = 0.0f;
    entry.trackTime = 0.0f;
    entry.trackLast = cast(f32, -1);
    entry.nextTrackLast = cast(f32, -1);
    entry.trackEnd = cast(f32, INT_MAX);
    entry.timeScale = 1.0f;
    entry.alpha = 1.0f;
    entry.mixTime = 0.0f;
    entry.mixDuration = cast(f32, last == null ? 0.0f : spAnimationStateData_getMix(self.data, last.animation, animation));
    entry.interruptAlpha = 1.0f;
    entry.totalAlpha = 0.0f;
    entry.mixBlend = SP_MIX_BLEND_REPLACE;
    entry.timelineMode = spIntArray_create(16);
    entry.timelineHoldMix = spTrackEntryArray_create(16);
    return entry;
}

void spAnimationState_clearNext(spAnimationState* self, spTrackEntry* entry) {
    var internal = cast(_spAnimationState*, self);
    spTrackEntry* next = entry.next;
    while next != null {
        _spEventQueue_dispose(internal.queue, next);
        next = next.next;
    }
    entry.next = null;
}

void _spAnimationState_animationsChanged(spAnimationState* self) {
    var internal = cast(_spAnimationState*, self);
    i32 i;
    i32 n;
    spTrackEntry* entry;
    internal.animationsChanged = 0;
    internal.propertyIDsCount = 0;
    i = 0;
    n = self.tracksCount;
    for ; i < n; i++ {
        entry = self.tracks[i];
        if entry == null {
            continue;
        }
        while entry.mixingFrom != null {
            entry = entry.mixingFrom;
        }
        while true {
            if entry.mixingTo == null || entry.mixBlend != SP_MIX_BLEND_ADD {
                _spTrackEntry_computeHold(entry, self);
            }
            entry = entry.mixingTo;
            if !(entry != null) { break; }
        }
    }
}

f32* _spAnimationState_resizeTimelinesRotation(spTrackEntry* entry, i32 newSize) {
    if entry.timelinesRotationCount != newSize {
        var newTimelinesRotation = cast(f32*, _spCalloc(cast(u64, newSize), cast(u64, sizeof(f32)), "extension.h", 77));
        _spFree(cast(void*, entry.timelinesRotation));
        entry.timelinesRotation = newTimelinesRotation;
        entry.timelinesRotationCount = newSize;
    }
    return entry.timelinesRotation;
}

void _spAnimationState_ensureCapacityPropertyIDs(spAnimationState* self, i32 capacity) {
    var internal = cast(_spAnimationState*, self);
    if internal.propertyIDsCapacity < capacity {
        var newPropertyIDs = cast(spPropertyId*, _spCalloc(cast(u64, capacity << 1), cast(u64, sizeof(spPropertyId)), "extension.h", 77));
        memcpy(newPropertyIDs, internal.propertyIDs, cast(u64, sizeof(spPropertyId) * internal.propertyIDsCount));
        _spFree(cast(void*, internal.propertyIDs));
        internal.propertyIDs = newPropertyIDs;
        internal.propertyIDsCapacity = capacity << 1;
    }
}

i32 _spAnimationState_addPropertyID(spAnimationState* self, spPropertyId id) {
    i32 i;
    i32 n;
    var internal = cast(_spAnimationState*, self);
    {
        i = 0;
        for n = internal.propertyIDsCount; i < n; i++ {
            if internal.propertyIDs[i] == id {
                return 0;
            }
        }
    }
    _spAnimationState_ensureCapacityPropertyIDs(self, internal.propertyIDsCount + 1);
    internal.propertyIDs[internal.propertyIDsCount] = id;
    internal.propertyIDsCount++;
    return 1;
}

i32 _spAnimationState_addPropertyIDs(spAnimationState* self, spPropertyId* ids, i32 numIds) {
    i32 i;
    i32 n;
    var internal = cast(_spAnimationState*, self);
    i32 oldSize = internal.propertyIDsCount;
    {
        i = 0;
        for n = numIds; i < n; i++ {
            _spAnimationState_addPropertyID(self, ids[i]);
        }
    }
    return internal.propertyIDsCount != oldSize;
}

spTrackEntry* spAnimationState_getCurrent(spAnimationState* self, i32 trackIndex) {
    if trackIndex >= self.tracksCount {
        return null;
    }
    return self.tracks[trackIndex];
}

void spAnimationState_clearListenerNotifications(spAnimationState* self) {
    var internal = cast(_spAnimationState*, self);
    _spEventQueue_clear(internal.queue);
}

f32 spTrackEntry_getAnimationTime(spTrackEntry* entry) {
    if entry.loop != 0 {
        f32 duration = entry.animationEnd - entry.animationStart;
        if duration == 0.0f {
            return entry.animationStart;
        }
        return fmodf(entry.trackTime, duration) + entry.animationStart;
    }
    return entry.trackTime + entry.animationStart < entry.animationEnd ? entry.trackTime + entry.animationStart : entry.animationEnd;
}

void spTrackEntry_resetRotationDirections(spTrackEntry* entry) {
    _spFree(cast(void*, entry.timelinesRotation));
    entry.timelinesRotation = null;
    entry.timelinesRotationCount = 0;
}

f32 spTrackEntry_getTrackComplete(spTrackEntry* entry) {
    f32 duration = entry.animationEnd - entry.animationStart;
    if duration != 0.0f {
        if entry.loop != 0 {
            return duration * cast(f32, 1 + cast(i32, entry.trackTime / duration));
        }
        if entry.trackTime < duration {
            return duration;
        }
    }
    return entry.trackTime;
}

void spTrackEntry_setMixDuration(spTrackEntry* entry, f32 mixDuration, f32 delay) {
    entry.mixDuration = mixDuration;
    if entry.previous && delay <= 0.0f {
        delay += spTrackEntry_getTrackComplete(entry) - mixDuration;
    }
    entry.delay = delay;
}

i32 spTrackEntry_wasApplied(spTrackEntry* entry) {
    return entry.nextTrackLast != -1.0f;
}

i32 spTrackEntry_isNextReady(spTrackEntry* entry) {
    return entry.next != null && entry.nextTrackLast - entry.next.delay >= 0.0f;
}

void _spTrackEntry_computeHold(spTrackEntry* entry, spAnimationState* state) {
    spTrackEntry* to;
    spTimeline** timelines;
    i32 timelinesCount;
    i32* timelineMode;
    spTrackEntry** timelineHoldMix;
    spTrackEntry* next;
    i32 i;
    to = entry.mixingTo;
    timelines = entry.animation.timelines.items;
    timelinesCount = entry.animation.timelines.size;
    timelineMode = spIntArray_setSize(entry.timelineMode, timelinesCount).items;
    spTrackEntryArray_clear(entry.timelineHoldMix);
    timelineHoldMix = spTrackEntryArray_setSize(entry.timelineHoldMix, timelinesCount).items;
    if to != null && to.holdPrevious {
        for i = 0; i < timelinesCount; i++ {
            spPropertyId* ids = timelines[i].propertyIds;
            i32 numIds = timelines[i].propertyIdsCount;
            timelineMode[i] = _spAnimationState_addPropertyIDs(state, ids, numIds) != 0 ? 3 : 2;
        }
        return;
    }
    i = 0;
    bool __retry_continue_outer = false;
    while true {
        __retry_continue_outer = false;
        {
            for ; i < timelinesCount; i++ {
                spTimeline* timeline = timelines[i];
                spPropertyId* ids = timeline.propertyIds;
                i32 numIds = timeline.propertyIdsCount;
                if _spAnimationState_addPropertyIDs(state, ids, numIds) == 0 {
                    timelineMode[i] = 0;
                } else if to == null || timeline.type == SP_TIMELINE_ATTACHMENT || timeline.type == SP_TIMELINE_DRAWORDER || timeline.type == SP_TIMELINE_EVENT || !spAnimation_hasTimeline(to.animation, ids, numIds) {
                    timelineMode[i] = 1;
                } else {
                    {
                        for next = to.mixingTo; next != null; next = next.mixingTo {
                            if spAnimation_hasTimeline(next.animation, ids, numIds) != 0 {
                                continue;
                            }
                            if next.mixDuration > 0.0f {
                                timelineMode[i] = 4;
                                timelineHoldMix[i] = next;
                                i++;
                                {
                                    __retry_continue_outer = true;
                                    break;
                                }
                            }
                            break;
                        }
                        if __retry_continue_outer {
                            break;
                        }
                    }
                    timelineMode[i] = 3;
                }
            }
            if __retry_continue_outer {
                continue;
            }
        }
        break;
    }
}

_ToEntry* _ToEntry_create(spAnimation* to, f32 duration) {
    var self = cast(_ToEntry*, _spCalloc(1, cast(u64, sizeof(_ToEntry)), "extension.h", 109));
    self.animation = to;
    self.duration = duration;
    return self;
}

void _ToEntry_dispose(_ToEntry* self) {
    _spFree(cast(void*, self));
}

_FromEntry* _FromEntry_create(spAnimation* from_var) {
    var self = cast(_FromEntry*, _spCalloc(1, cast(u64, sizeof(_FromEntry)), "extension.h", 109));
    self.animation = from_var;
    return self;
}

void _FromEntry_dispose(_FromEntry* self) {
    _spFree(cast(void*, self));
}

/**/
spAnimationStateData* spAnimationStateData_create(spSkeletonData* skeletonData) {
    var self = cast(spAnimationStateData*, _spCalloc(1, cast(u64, sizeof(spAnimationStateData)), "extension.h", 109));
    self.skeletonData = skeletonData;
    return self;
}

void spAnimationStateData_dispose(spAnimationStateData* self) {
    _ToEntry* toEntry;
    _ToEntry* nextToEntry;
    _FromEntry* nextFromEntry;
    var fromEntry = cast(_FromEntry*, self.entries);
    while fromEntry != null {
        toEntry = fromEntry.toEntries;
        while toEntry != null {
            nextToEntry = toEntry.next;
            _ToEntry_dispose(toEntry);
            toEntry = nextToEntry;
        }
        nextFromEntry = fromEntry.next;
        _FromEntry_dispose(fromEntry);
        fromEntry = nextFromEntry;
    }
    _spFree(cast(void*, self));
}

void spAnimationStateData_setMixByName(spAnimationStateData* self, u8* fromName, u8* toName, f32 duration) {
    spAnimation* to;
    spAnimation* from_var = spSkeletonData_findAnimation(self.skeletonData, fromName);  // renamed from: from
    if from_var == null {
        return;
    }
    to = spSkeletonData_findAnimation(self.skeletonData, toName);
    if to == null {
        return;
    }
    spAnimationStateData_setMix(self, from_var, to, duration);
}

void spAnimationStateData_setMix(spAnimationStateData* self, spAnimation* from_var, spAnimation* to, f32 duration) {
    _ToEntry* toEntry;
    var fromEntry = cast(_FromEntry*, self.entries);
    while fromEntry != null {
        if fromEntry.animation == from_var {
            toEntry = fromEntry.toEntries;
            while toEntry != null {
                if toEntry.animation == to {
                    toEntry.duration = duration;
                    return;
                }
                toEntry = toEntry.next;
            }
            break;
        }
        fromEntry = fromEntry.next;
    }
    if fromEntry == null {
        fromEntry = _FromEntry_create(from_var);
        fromEntry.next = cast(_FromEntry*, self.entries);
        self.entries = fromEntry;
    }
    toEntry = _ToEntry_create(to, duration);
    toEntry.next = fromEntry.toEntries;
    fromEntry.toEntries = toEntry;
}

f32 spAnimationStateData_getMix(spAnimationStateData* self, spAnimation* from_var, spAnimation* to) {
    var fromEntry = cast(_FromEntry*, self.entries);
    while fromEntry != null {
        if fromEntry.animation == from_var {
            _ToEntry* toEntry = fromEntry.toEntries;
            while toEntry != null {
                if toEntry.animation == to {
                    return toEntry.duration;
                }
                toEntry = toEntry.next;
            }
        }
        fromEntry = fromEntry.next;
    }
    return self.defaultMix;
}

spFloatArray* spFloatArray_create(i32 initialCapacity) {
    var array = cast(spFloatArray*, _spCalloc(1, cast(u64, sizeof(spFloatArray)), "extension.h", 44));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(f32*, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(f32)), "extension.h", 44));
    return array;
}

void spFloatArray_dispose(spFloatArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spFloatArray_clear(spFloatArray* self) {
    self.size = 0;
}

spFloatArray* spFloatArray_setSize(spFloatArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(f32*, _spRealloc(self.items, cast(u64, sizeof(f32) * self.capacity)));
    }
    return self;
}

void spFloatArray_ensureCapacity(spFloatArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(f32*, _spRealloc(self.items, cast(u64, sizeof(f32) * self.capacity)));
}

void spFloatArray_add(spFloatArray* self, f32 value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(f32*, _spRealloc(self.items, cast(u64, sizeof(f32) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spFloatArray_addAll(spFloatArray* self, spFloatArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spFloatArray_add(self, other.items[i]);
    }
}

void spFloatArray_addAllValues(spFloatArray* self, f32* values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spFloatArray_add(self, values[i]);
    }
}

void spFloatArray_removeAt(spFloatArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(f32) * (self.size - index)));
}

i32 spFloatArray_contains(spFloatArray* self, f32 value) {
    f32* items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

f32 spFloatArray_pop(spFloatArray* self) {
    f32 item = self.items[--self.size];
    return item;
}

f32 spFloatArray_peek(spFloatArray* self) {
    return self.items[self.size - 1];
}

spIntArray* spIntArray_create(i32 initialCapacity) {
    var array = cast(spIntArray*, _spCalloc(1, cast(u64, sizeof(spIntArray)), "extension.h", 44));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(i32*, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(i32)), "extension.h", 44));
    return array;
}

void spIntArray_dispose(spIntArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spIntArray_clear(spIntArray* self) {
    self.size = 0;
}

spIntArray* spIntArray_setSize(spIntArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(i32*, _spRealloc(self.items, cast(u64, sizeof(i32) * self.capacity)));
    }
    return self;
}

void spIntArray_ensureCapacity(spIntArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(i32*, _spRealloc(self.items, cast(u64, sizeof(i32) * self.capacity)));
}

void spIntArray_add(spIntArray* self, i32 value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(i32*, _spRealloc(self.items, cast(u64, sizeof(i32) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spIntArray_addAll(spIntArray* self, spIntArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spIntArray_add(self, other.items[i]);
    }
}

void spIntArray_addAllValues(spIntArray* self, i32* values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spIntArray_add(self, values[i]);
    }
}

void spIntArray_removeAt(spIntArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(i32) * (self.size - index)));
}

i32 spIntArray_contains(spIntArray* self, i32 value) {
    i32* items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

i32 spIntArray_pop(spIntArray* self) {
    i32 item = self.items[--self.size];
    return item;
}

i32 spIntArray_peek(spIntArray* self) {
    return self.items[self.size - 1];
}

spShortArray* spShortArray_create(i32 initialCapacity) {
    var array = cast(spShortArray*, _spCalloc(1, cast(u64, sizeof(spShortArray)), "extension.h", 44));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(i16*, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(i16)), "extension.h", 44));
    return array;
}

void spShortArray_dispose(spShortArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spShortArray_clear(spShortArray* self) {
    self.size = 0;
}

spShortArray* spShortArray_setSize(spShortArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(i16*, _spRealloc(self.items, cast(u64, sizeof(i16) * self.capacity)));
    }
    return self;
}

void spShortArray_ensureCapacity(spShortArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(i16*, _spRealloc(self.items, cast(u64, sizeof(i16) * self.capacity)));
}

void spShortArray_add(spShortArray* self, i16 value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(i16*, _spRealloc(self.items, cast(u64, sizeof(i16) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spShortArray_addAll(spShortArray* self, spShortArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spShortArray_add(self, other.items[i]);
    }
}

void spShortArray_addAllValues(spShortArray* self, i16* values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spShortArray_add(self, values[i]);
    }
}

void spShortArray_removeAt(spShortArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(i16) * (self.size - index)));
}

i32 spShortArray_contains(spShortArray* self, i16 value) {
    i16* items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

i16 spShortArray_pop(spShortArray* self) {
    i16 item = self.items[--self.size];
    return item;
}

i16 spShortArray_peek(spShortArray* self) {
    return self.items[self.size - 1];
}

spUnsignedShortArray* spUnsignedShortArray_create(i32 initialCapacity) {
    var array = cast(spUnsignedShortArray*, _spCalloc(1, cast(u64, sizeof(spUnsignedShortArray)), "extension.h", 44));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(u16*, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(u16)), "extension.h", 44));
    return array;
}

void spUnsignedShortArray_dispose(spUnsignedShortArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spUnsignedShortArray_clear(spUnsignedShortArray* self) {
    self.size = 0;
}

spUnsignedShortArray* spUnsignedShortArray_setSize(spUnsignedShortArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(u16*, _spRealloc(self.items, cast(u64, sizeof(u16) * self.capacity)));
    }
    return self;
}

void spUnsignedShortArray_ensureCapacity(spUnsignedShortArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(u16*, _spRealloc(self.items, cast(u64, sizeof(u16) * self.capacity)));
}

void spUnsignedShortArray_add(spUnsignedShortArray* self, u16 value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(u16*, _spRealloc(self.items, cast(u64, sizeof(u16) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spUnsignedShortArray_addAll(spUnsignedShortArray* self, spUnsignedShortArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spUnsignedShortArray_add(self, other.items[i]);
    }
}

void spUnsignedShortArray_addAllValues(spUnsignedShortArray* self, u16* values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spUnsignedShortArray_add(self, values[i]);
    }
}

void spUnsignedShortArray_removeAt(spUnsignedShortArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(u16) * (self.size - index)));
}

i32 spUnsignedShortArray_contains(spUnsignedShortArray* self, u16 value) {
    u16* items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

u16 spUnsignedShortArray_pop(spUnsignedShortArray* self) {
    u16 item = self.items[--self.size];
    return item;
}

u16 spUnsignedShortArray_peek(spUnsignedShortArray* self) {
    return self.items[self.size - 1];
}

spArrayFloatArray* spArrayFloatArray_create(i32 initialCapacity) {
    var array = cast(spArrayFloatArray*, _spCalloc(1, cast(u64, sizeof(spArrayFloatArray)), "extension.h", 44));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spFloatArray**, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spFloatArray*)), "extension.h", 44));
    return array;
}

void spArrayFloatArray_dispose(spArrayFloatArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spArrayFloatArray_clear(spArrayFloatArray* self) {
    self.size = 0;
}

spArrayFloatArray* spArrayFloatArray_setSize(spArrayFloatArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spFloatArray**, _spRealloc(self.items, cast(u64, sizeof(spFloatArray*) * self.capacity)));
    }
    return self;
}

void spArrayFloatArray_ensureCapacity(spArrayFloatArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spFloatArray**, _spRealloc(self.items, cast(u64, sizeof(spFloatArray*) * self.capacity)));
}

void spArrayFloatArray_add(spArrayFloatArray* self, spFloatArray* value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spFloatArray**, _spRealloc(self.items, cast(u64, sizeof(spFloatArray*) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spArrayFloatArray_addAll(spArrayFloatArray* self, spArrayFloatArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spArrayFloatArray_add(self, other.items[i]);
    }
}

void spArrayFloatArray_addAllValues(spArrayFloatArray* self, spFloatArray** values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spArrayFloatArray_add(self, values[i]);
    }
}

void spArrayFloatArray_removeAt(spArrayFloatArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spFloatArray*) * (self.size - index)));
}

i32 spArrayFloatArray_contains(spArrayFloatArray* self, spFloatArray* value) {
    spFloatArray** items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spFloatArray* spArrayFloatArray_pop(spArrayFloatArray* self) {
    spFloatArray* item = self.items[--self.size];
    return item;
}

spFloatArray* spArrayFloatArray_peek(spArrayFloatArray* self) {
    return self.items[self.size - 1];
}

spArrayShortArray* spArrayShortArray_create(i32 initialCapacity) {
    var array = cast(spArrayShortArray*, _spCalloc(1, cast(u64, sizeof(spArrayShortArray)), "extension.h", 44));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spShortArray**, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spShortArray*)), "extension.h", 44));
    return array;
}

void spArrayShortArray_dispose(spArrayShortArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spArrayShortArray_clear(spArrayShortArray* self) {
    self.size = 0;
}

spArrayShortArray* spArrayShortArray_setSize(spArrayShortArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spShortArray**, _spRealloc(self.items, cast(u64, sizeof(spShortArray*) * self.capacity)));
    }
    return self;
}

void spArrayShortArray_ensureCapacity(spArrayShortArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spShortArray**, _spRealloc(self.items, cast(u64, sizeof(spShortArray*) * self.capacity)));
}

void spArrayShortArray_add(spArrayShortArray* self, spShortArray* value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spShortArray**, _spRealloc(self.items, cast(u64, sizeof(spShortArray*) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spArrayShortArray_addAll(spArrayShortArray* self, spArrayShortArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spArrayShortArray_add(self, other.items[i]);
    }
}

void spArrayShortArray_addAllValues(spArrayShortArray* self, spShortArray** values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spArrayShortArray_add(self, values[i]);
    }
}

void spArrayShortArray_removeAt(spArrayShortArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spShortArray*) * (self.size - index)));
}

i32 spArrayShortArray_contains(spArrayShortArray* self, spShortArray* value) {
    spShortArray** items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spShortArray* spArrayShortArray_pop(spArrayShortArray* self) {
    spShortArray* item = self.items[--self.size];
    return item;
}

spShortArray* spArrayShortArray_peek(spArrayShortArray* self) {
    return self.items[self.size - 1];
}

spKeyValueArray* spKeyValueArray_create(i32 initialCapacity) {
    var array = cast(spKeyValueArray*, _spCalloc(1, cast(u64, sizeof(spKeyValueArray)), "_file_name_", 39));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spKeyValue*, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spKeyValue)), "_file_name_", 39));
    return array;
}

void spKeyValueArray_dispose(spKeyValueArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spKeyValueArray_clear(spKeyValueArray* self) {
    self.size = 0;
}

spKeyValueArray* spKeyValueArray_setSize(spKeyValueArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spKeyValue*, _spRealloc(self.items, cast(u64, sizeof(spKeyValue) * self.capacity)));
    }
    return self;
}

void spKeyValueArray_ensureCapacity(spKeyValueArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spKeyValue*, _spRealloc(self.items, cast(u64, sizeof(spKeyValue) * self.capacity)));
}

void spKeyValueArray_add(spKeyValueArray* self, spKeyValue value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spKeyValue*, _spRealloc(self.items, cast(u64, sizeof(spKeyValue) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spKeyValueArray_addAll(spKeyValueArray* self, spKeyValueArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spKeyValueArray_add(self, other.items[i]);
    }
}

void spKeyValueArray_addAllValues(spKeyValueArray* self, spKeyValue* values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spKeyValueArray_add(self, values[i]);
    }
}

i32 spKeyValueArray_contains(spKeyValueArray* self, spKeyValue value) {
    spKeyValue* items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if strcmp(items[i].name, value.name) == 0 {
                return -1;
            }
        }
    }
    return 0;
}

spKeyValue spKeyValueArray_pop(spKeyValueArray* self) {
    spKeyValue item = self.items[--self.size];
    return item;
}

spKeyValue spKeyValueArray_peek(spKeyValueArray* self) {
    return self.items[self.size - 1];
}

spAtlasPage* spAtlasPage_create(spAtlas* atlas, u8* name) {
    var self = cast(spAtlasPage*, _spCalloc(1, cast(u64, sizeof(spAtlasPage)), "extension.h", 79));
    self.atlas = atlas;
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 77));
    strcpy(self.name, name);
    self.minFilter = SP_ATLAS_NEAREST;
    self.magFilter = SP_ATLAS_NEAREST;
    self.format = SP_ATLAS_RGBA8888;
    self.uWrap = SP_ATLAS_CLAMPTOEDGE;
    self.vWrap = SP_ATLAS_CLAMPTOEDGE;
    return self;
}

void spAtlasPage_dispose(spAtlasPage* self) {
    _spAtlasPage_disposeTexture(self);
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self));
}

/**/
spAtlasRegion* spAtlasRegion_create() {
    var region = cast(spAtlasRegion*, _spCalloc(1, cast(u64, sizeof(spAtlasRegion)), "extension.h", 79));
    region.keyValues = spKeyValueArray_create(2);
    return region;
}

void spAtlasRegion_dispose(spAtlasRegion* self) {
    i32 i;
    i32 n;
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self.splits));
    _spFree(cast(void*, self.pads));
    {
        i = 0;
        for n = self.keyValues.size; i < n; i++ {
            _spFree(cast(void*, self.keyValues.items[i].name));
        }
    }
    spKeyValueArray_dispose(self.keyValues);
    _spFree(cast(void*, self));
}

private {
SimpleString* ss_trim(SimpleString* self) {
    while isspace(cast(u8, *self.start)) && self.start < self.end {
        self.start++;
    }
    if self.start == self.end {
        self.length = cast(i32, cast(i64, self.end - self.start));
        return self;
    }
    self.end--;
    while cast(u8, *self.end) == 13 && self.end >= self.start {
        self.end--;
    }
    self.end++;
    self.length = cast(i32, cast(i64, self.end - self.start));
    return self;
}

i32 ss_indexOf(SimpleString* self, u8 needle) {
    u8* c = self.start;
    while c < self.end {
        if *c == needle {
            return cast(i32, cast(i64, c - self.start));
        }
        c++;
    }
    return -1;
}

i32 ss_indexOf2(SimpleString* self, u8 needle, i32 at) {
    u8* c = self.start + at;
    while c < self.end {
        if *c == needle {
            return cast(i32, cast(i64, c - self.start));
        }
        c++;
    }
    return -1;
}

SimpleString ss_substr(SimpleString* self, i32 s, i32 e) {
    noinit SimpleString result;
    e = s + e;
    result.start = self.start + s;
    result.end = self.start + e;
    result.length = e - s;
    return result;
}

SimpleString ss_substr2(SimpleString* self, i32 s) {
    noinit SimpleString result;
    result.start = self.start + s;
    result.end = self.end;
    result.length = cast(i32, cast(i64, result.end - result.start));
    return result;
}

i32 ss_equals(SimpleString* self, u8* str_var) {
    i32 i;
    var otherLen = cast(i32, strlen(str_var));
    if self.length != otherLen {
        return 0;
    }
    for i = 0; i < self.length; i++ {
        if self.start[i] != str_var[i] {
            return 0;
        }
    }
    return -1;
}

u8* ss_copy(SimpleString* self) {
    var string_var = cast(u8*, _spCalloc(cast(u64, self.length + 1), cast(u64, sizeof(u8)), "extension.h", 79));  // renamed from: string
    memcpy(string_var, self.start, cast(u64, self.length));
    string_var[self.length] = 0;
    return string_var;
}

i32 ss_toInt(SimpleString* self) {
    return cast(i32, strtol(self.start, &self.end, 10));
}

SimpleString* ai_readLine(AtlasInput* self) {
    if self.index >= self.end {
        return null;
    }
    self.line.start = self.index;
    while self.index < self.end && *self.index != 10 {
        self.index++;
    }
    self.line.end = self.index;
    if self.index != self.end {
        self.index++;
    }
    self.line = *ss_trim(&self.line);
    self.line.length = cast(i32, cast(i64, self.line.end - self.line.start));
    return &self.line;
}

i32 ai_readEntry(SimpleString* entry, SimpleString* line) {
    i32 colon;
    i32 i;
    i32 lastMatch;
    noinit SimpleString substr;
    if line == null {
        return 0;
    }
    ss_trim(line);
    if line.length == 0 {
        return 0;
    }
    colon = ss_indexOf(line, 58);
    if colon == -1 {
        return 0;
    }
    substr = ss_substr(line, 0, colon);
    entry[0] = *ss_trim(&substr);
    {
        i = 1;
        for lastMatch = colon + 1; true; i++ {
            i32 comma = ss_indexOf2(line, 44, lastMatch);
            if comma == -1 {
                substr = ss_substr2(line, lastMatch);
                entry[i] = *ss_trim(&substr);
                return i;
            }
            substr = ss_substr(line, lastMatch, comma - lastMatch);
            entry[i] = *ss_trim(&substr);
            lastMatch = comma + 1;
            if i == 4 {
                return 4;
            }
        }
    }
}
u8*[8] formatNames = {
    "", "Alpha", "Intensity", "LuminanceAlpha", "RGB565", "RGBA4444", "RGB888", "RGBA8888",
};
u8*[8] textureFilterNames = {
    "", "Nearest", "Linear", "MipMap", "MipMapNearestNearest", "MipMapLinearNearest",
    "MipMapNearestLinear", "MipMapLinearLinear",
};
}

i32 indexOf(u8** array, i32 count, SimpleString* str_var) {
    i32 i;
    for i = 0; i < count; i++ {
        if ss_equals(str_var, array[i]) != 0 {
            return i;
        }
    }
    return 0;
}

spAtlas* spAtlas_create(u8* begin, i32 length, u8* dir, void* rendererObject) {
    spAtlas* self;
    noinit AtlasInput reader;
    SimpleString* line;
    noinit SimpleString[5] entry;
    spAtlasPage* page = null;
    spAtlasPage* lastPage = null;
    spAtlasRegion* lastRegion = null;
    i32 count;
    var dirLength = cast(i32, strlen(dir));
    i32 needsSlash = dirLength > 0 && dir[dirLength - 1] != 47 && dir[dirLength - 1] != 92;
    self = cast(spAtlas*, _spCalloc(1, cast(u64, sizeof(spAtlas)), "extension.h", 79));
    self.rendererObject = rendererObject;
    reader.start = begin;
    reader.end = begin + length;
    reader.index = begin;
    reader.length = length;
    line = ai_readLine(&reader);
    while line != null && line.length == 0 {
        line = ai_readLine(&reader);
    }
    while -1 != 0 {
        if line == null || line.length == 0 {
            break;
        }
        if ai_readEntry(entry, line) == 0 {
            break;
        }
        line = ai_readLine(&reader);
    }
    while -1 != 0 {
        if line == null {
            break;
        }
        if ss_trim(line).length == 0 {
            page = null;
            line = ai_readLine(&reader);
        } else if page == null {
            u8* name = ss_copy(line);
            var path = cast(u8*, _spCalloc(cast(u64, dirLength + needsSlash) + strlen(name) + 1, cast(u64, sizeof(u8)), "extension.h", 79));
            memcpy(path, dir, cast(u64, dirLength));
            if needsSlash != 0 {
                path[dirLength] = 47;
            }
            strcpy(path + dirLength + needsSlash, name);
            page = spAtlasPage_create(self, name);
            _spFree(cast(void*, name));
            if lastPage != null {
                lastPage.next = page;
            } else {
                self.pages = page;
            }
            lastPage = page;
            while -1 != 0 {
                line = ai_readLine(&reader);
                if ai_readEntry(entry, line) == 0 {
                    break;
                }
                if ss_equals(&entry[0], "size") != 0 {
                    page.width = ss_toInt(&entry[1]);
                    page.height = ss_toInt(&entry[2]);
                } else if ss_equals(&entry[0], "format") != 0 {
                    page.format = cast(spAtlasFormat, indexOf(formatNames, 8, &entry[1]));
                } else if ss_equals(&entry[0], "filter") != 0 {
                    page.minFilter = cast(spAtlasFilter, indexOf(textureFilterNames, 8, &entry[1]));
                    page.magFilter = cast(spAtlasFilter, indexOf(textureFilterNames, 8, &entry[2]));
                } else if ss_equals(&entry[0], "repeat") != 0 {
                    page.uWrap = SP_ATLAS_CLAMPTOEDGE;
                    page.vWrap = SP_ATLAS_CLAMPTOEDGE;
                    if ss_indexOf(&entry[1], 120) != -1 {
                        page.uWrap = SP_ATLAS_REPEAT;
                    }
                    if ss_indexOf(&entry[1], 121) != -1 {
                        page.vWrap = SP_ATLAS_REPEAT;
                    }
                } else if ss_equals(&entry[0], "pma") != 0 {
                    page.pma = ss_equals(&entry[1], "true");
                }
            }
            _spAtlasPage_createTexture(page, path);
            _spFree(cast(void*, path));
        } else {
            spAtlasRegion* region = spAtlasRegion_create();
            if lastRegion != null {
                lastRegion.next = region;
            } else {
                self.regions = region;
            }
            lastRegion = region;
            region.page = page;
            region.name = ss_copy(line);
            while -1 != 0 {
                line = ai_readLine(&reader);
                count = ai_readEntry(entry, line);
                if count == 0 {
                    break;
                }
                if ss_equals(&entry[0], "xy") != 0 {
                    region.x = ss_toInt(&entry[1]);
                    region.y = ss_toInt(&entry[2]);
                } else if ss_equals(&entry[0], "size") != 0 {
                    region.super.width = ss_toInt(&entry[1]);
                    region.super.height = ss_toInt(&entry[2]);
                } else if ss_equals(&entry[0], "bounds") != 0 {
                    region.x = ss_toInt(&entry[1]);
                    region.y = ss_toInt(&entry[2]);
                    region.super.width = ss_toInt(&entry[3]);
                    region.super.height = ss_toInt(&entry[4]);
                } else if ss_equals(&entry[0], "offset") != 0 {
                    region.super.offsetX = cast(f32, ss_toInt(&entry[1]));
                    region.super.offsetY = cast(f32, ss_toInt(&entry[2]));
                } else if ss_equals(&entry[0], "orig") != 0 {
                    region.super.originalWidth = ss_toInt(&entry[1]);
                    region.super.originalHeight = ss_toInt(&entry[2]);
                } else if ss_equals(&entry[0], "offsets") != 0 {
                    region.super.offsetX = cast(f32, ss_toInt(&entry[1]));
                    region.super.offsetY = cast(f32, ss_toInt(&entry[2]));
                    region.super.originalWidth = ss_toInt(&entry[3]);
                    region.super.originalHeight = ss_toInt(&entry[4]);
                } else if ss_equals(&entry[0], "rotate") != 0 {
                    if ss_equals(&entry[1], "true") != 0 {
                        region.super.degrees = 90;
                    } else if ss_equals(&entry[1], "false") == 0 {
                        region.super.degrees = ss_toInt(&entry[1]);
                    }
                } else if ss_equals(&entry[0], "index") != 0 {
                    region.index = ss_toInt(&entry[1]);
                } else {
                    i32 i = 0;
                    noinit spKeyValue keyValue;
                    keyValue.name = ss_copy(&entry[0]);
                    for i = 0; i < count; i++ {
                        keyValue.values[i] = cast(f32, ss_toInt(&entry[i + 1]));
                    }
                    spKeyValueArray_add(region.keyValues, keyValue);
                }
            }
            if region.super.originalWidth == 0 && region.super.originalHeight == 0 {
                region.super.originalWidth = region.super.width;
                region.super.originalHeight = region.super.height;
            }
            region.super.u = cast(f32, region.x) / cast(f32, page.width);
            region.super.v = cast(f32, region.y) / cast(f32, page.height);
            if region.super.degrees == 90 {
                region.super.u2 = cast(f32, region.x + region.super.height) / cast(f32, page.width);
                region.super.v2 = cast(f32, region.y + region.super.width) / cast(f32, page.height);
            } else {
                region.super.u2 = cast(f32, region.x + region.super.width) / cast(f32, page.width);
                region.super.v2 = cast(f32, region.y + region.super.height) / cast(f32, page.height);
            }
        }
    }
    return self;
}

spAtlas* spAtlas_createFromFile(u8* path, void* rendererObject) {
    i32 dirLength;
    u8* dir;
    i32 length;
    u8* data;
    spAtlas* atlas = null;
    u8* lastForwardSlash = strrchr(path, 47);
    u8* lastBackwardSlash = strrchr(path, 92);
    u8* lastSlash = lastForwardSlash > lastBackwardSlash ? lastForwardSlash : lastBackwardSlash;
    if lastSlash == path {
        lastSlash++;
    }
    dirLength = cast(i32, lastSlash != null ? cast(i64, lastSlash - path) : 0);
    dir = cast(u8*, _spMalloc(cast(u64, sizeof(u8) * (dirLength + 1)), "extension.h", 77));
    memcpy(dir, path, cast(u64, dirLength));
    dir[dirLength] = 0;
    data = _spUtil_readFile(path, &length);
    if data != null {
        atlas = spAtlas_create(data, length, dir, rendererObject);
    }
    _spFree(cast(void*, data));
    _spFree(cast(void*, dir));
    return atlas;
}

void spAtlas_dispose(spAtlas* self) {
    spAtlasRegion* region;
    spAtlasRegion* nextRegion;
    spAtlasPage* page = self.pages;
    while page != null {
        spAtlasPage* nextPage = page.next;
        spAtlasPage_dispose(page);
        page = nextPage;
    }
    region = self.regions;
    while region != null {
        nextRegion = region.next;
        spAtlasRegion_dispose(region);
        region = nextRegion;
    }
    _spFree(cast(void*, self));
}

spAtlasRegion* spAtlas_findRegion(spAtlas* self, u8* name) {
    spAtlasRegion* region = self.regions;
    while region != null {
        if strcmp(region.name, name) == 0 {
            return region;
        }
        region = region.next;
    }
    return null;
}

private {
i32 loadSequence(spAtlas* atlas, u8* basePath, spSequence* sequence) {
    spTextureRegionArray* regions = sequence.regions;
    var path = cast(u8*, _spCalloc(strlen(basePath) + cast(u64, sequence.digits) + 2, cast(u64, sizeof(u8)), "extension.h", 82));
    i32 i;
    for i = 0; i < regions.size; i++ {
        spSequence_getPath(sequence, basePath, i, path);
        regions.items[i] = &spAtlas_findRegion(atlas, path).super;
        if regions.items[i] == null {
            _spFree(cast(void*, path));
            return 0;
        }
        regions.items[i].rendererObject = regions.items[i];
    }
    _spFree(cast(void*, path));
    return -1;
}
}

spAttachment* _spAtlasAttachmentLoader_createAttachment(spAttachmentLoader* loader, spSkin* skin, spAttachmentType type, u8* name, u8* path, spSequence* sequence) {
    var self = cast(spAtlasAttachmentLoader*, loader);
    switch type {
        case SP_ATTACHMENT_REGION: {
            {
                spRegionAttachment* attachment = spRegionAttachment_create(name);
                if sequence != null {
                    if loadSequence(self.atlas, path, sequence) == 0 {
                        spAttachment_dispose(&attachment.super);
                        _spAttachmentLoader_setError(loader, "Couldn't load sequence for region attachment: ", path);
                        return null;
                    }
                } else {
                    spAtlasRegion* region = spAtlas_findRegion(self.atlas, path);
                    if region == null {
                        spAttachment_dispose(&attachment.super);
                        _spAttachmentLoader_setError(loader, "Region not found: ", path);
                        return null;
                    }
                    attachment.rendererObject = region;
                    attachment.region = &region.super;
                }
                return &attachment.super;
            }
        }
        case SP_ATTACHMENT_MESH, SP_ATTACHMENT_LINKED_MESH: {
            {
                spMeshAttachment* attachment = spMeshAttachment_create(name);
                if sequence != null {
                    if loadSequence(self.atlas, path, sequence) == 0 {
                        spAttachment_dispose(&attachment.super.super);
                        _spAttachmentLoader_setError(loader, "Couldn't load sequence for mesh attachment: ", path);
                        return null;
                    }
                } else {
                    spAtlasRegion* region = spAtlas_findRegion(self.atlas, path);
                    if region == null {
                        _spAttachmentLoader_setError(loader, "Region not found: ", path);
                        return null;
                    }
                    attachment.rendererObject = region;
                    attachment.region = &region.super;
                }
                return &attachment.super.super;
            }
        }
        case SP_ATTACHMENT_BOUNDING_BOX: {
            return &spBoundingBoxAttachment_create(name).super.super;
        }
        case SP_ATTACHMENT_PATH: {
            return &spPathAttachment_create(name).super.super;
        }
        case SP_ATTACHMENT_POINT: {
            return &spPointAttachment_create(name).super;
        }
        case SP_ATTACHMENT_CLIPPING: {
            return &spClippingAttachment_create(name).super.super;
        }
        default: {
            _spAttachmentLoader_setUnknownTypeError(loader, type);
            return null;
        }
    }
    ignore skin;
}

spAtlasAttachmentLoader* spAtlasAttachmentLoader_create(spAtlas* atlas) {
    var self = cast(spAtlasAttachmentLoader*, _spCalloc(1, cast(u64, sizeof(spAtlasAttachmentLoader)), "extension.h", 82));
    _spAttachmentLoader_init(&self.super, cast(fn(spAttachmentLoader*): void, _spAttachmentLoader_deinit), cast(fn(spAttachmentLoader*, spSkin*, spAttachmentType, u8*, u8*, spSequence*): spAttachment*, _spAtlasAttachmentLoader_createAttachment), null, null);
    self.atlas = atlas;
    return self;
}

void _spAttachment_init(spAttachment* self, u8* name, spAttachmentType type, fn(spAttachment*): void dispose, fn(spAttachment*): spAttachment* copy) {
    self.vtable = cast(_spAttachmentVtable*, _spCalloc(1, cast(u64, sizeof(_spAttachmentVtable)), "extension.h", 66));
    cast(_spAttachmentVtable*, self.vtable).dispose = dispose;
    cast(_spAttachmentVtable*, self.vtable).copy = copy;
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 66));
    strcpy(self.name, name);
    self.type = type;
}

void _spAttachment_deinit(spAttachment* self) {
    if self.attachmentLoader != null {
        spAttachmentLoader_disposeAttachment(self.attachmentLoader, self);
    }
    _spFree(self.vtable);
    _spFree(cast(void*, self.name));
}

spAttachment* spAttachment_copy(spAttachment* self) {
    return cast(_spAttachmentVtable*, self.vtable).copy(self);
}

void spAttachment_dispose(spAttachment* self) {
    self.refCount--;
    if self.refCount <= 0 {
        cast(_spAttachmentVtable*, self.vtable).dispose(self);
    }
}

void _spAttachmentLoader_init(spAttachmentLoader* self, fn(spAttachmentLoader*): void dispose, fn(spAttachmentLoader*, spSkin*, spAttachmentType, u8*, u8*, spSequence*): spAttachment* createAttachment, fn(spAttachmentLoader*, spAttachment*): void configureAttachment, fn(spAttachmentLoader*, spAttachment*): void disposeAttachment) {
    self.vtable = cast(_spAttachmentLoaderVtable*, _spCalloc(1, cast(u64, sizeof(_spAttachmentLoaderVtable)), "extension.h", 77));
    cast(_spAttachmentLoaderVtable*, self.vtable).dispose = dispose;
    cast(_spAttachmentLoaderVtable*, self.vtable).createAttachment = createAttachment;
    cast(_spAttachmentLoaderVtable*, self.vtable).configureAttachment = configureAttachment;
    cast(_spAttachmentLoaderVtable*, self.vtable).disposeAttachment = disposeAttachment;
}

void _spAttachmentLoader_deinit(spAttachmentLoader* self) {
    _spFree(self.vtable);
    _spFree(cast(void*, self.error1));
    _spFree(cast(void*, self.error2));
}

void spAttachmentLoader_dispose(spAttachmentLoader* self) {
    cast(_spAttachmentLoaderVtable*, self.vtable).dispose(self);
    _spFree(cast(void*, self));
}

spAttachment* spAttachmentLoader_createAttachment(spAttachmentLoader* self, spSkin* skin, spAttachmentType type, u8* name, u8* path, spSequence* sequence) {
    _spFree(cast(void*, self.error1));
    _spFree(cast(void*, self.error2));
    self.error1 = null;
    self.error2 = null;
    return cast(_spAttachmentLoaderVtable*, self.vtable).createAttachment(self, skin, type, name, path, sequence);
}

void spAttachmentLoader_configureAttachment(spAttachmentLoader* self, spAttachment* attachment) {
    if cast(_spAttachmentLoaderVtable*, self.vtable).configureAttachment == null {
        return;
    }
    cast(_spAttachmentLoaderVtable*, self.vtable).configureAttachment(self, attachment);
}

void spAttachmentLoader_disposeAttachment(spAttachmentLoader* self, spAttachment* attachment) {
    if cast(_spAttachmentLoaderVtable*, self.vtable).disposeAttachment == null {
        return;
    }
    cast(_spAttachmentLoaderVtable*, self.vtable).disposeAttachment(self, attachment);
}

void _spAttachmentLoader_setError(spAttachmentLoader* self, u8* error1, u8* error2) {
    _spFree(cast(void*, self.error1));
    _spFree(cast(void*, self.error2));
    self.error1 = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(error1) + 1), "extension.h", 74));
    strcpy(self.error1, error1);
    self.error2 = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(error2) + 1), "extension.h", 74));
    strcpy(self.error2, error2);
}

void _spAttachmentLoader_setUnknownTypeError(spAttachmentLoader* self, spAttachmentType type) {
    noinit u8[16] buffer;
    snprintf(buffer, 16, "%d", type);
    _spAttachmentLoader_setError(self, "Unknown attachment type: ", buffer);
}
private { i32 yDown; }

void spBone_setYDown(i32 value) {
    yDown = value;
}

i32 spBone_isYDown() {
    return yDown;
}

spBone* spBone_create(spBoneData* data, spSkeleton* skeleton, spBone* parent) {
    var self = cast(spBone*, _spCalloc(1, cast(u64, sizeof(spBone)), "extension.h", 103));
    self.data = data;
    self.skeleton = skeleton;
    self.parent = parent;
    self.a = 1.0f;
    self.d = 1.0f;
    self.active = -1;
    self.inherit = SP_INHERIT_NORMAL;
    spBone_setToSetupPose(self);
    return self;
}

void spBone_dispose(spBone* self) {
    _spFree(cast(void*, self.children));
    _spFree(cast(void*, self));
}

void spBone_update(spBone* self) {
    spBone_updateWorldTransformWith(self, self.ax, self.ay, self.arotation, self.ascaleX, self.ascaleY, self.ashearX, self.ashearY);
}

void spBone_updateWorldTransform(spBone* self) {
    spBone_updateWorldTransformWith(self, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.shearX, self.shearY);
}

void spBone_updateWorldTransformWith(spBone* self, f32 x, f32 y, f32 rotation, f32 scaleX, f32 scaleY, f32 shearX, f32 shearY) {
    f32 pa;
    f32 pb;
    f32 pc;
    f32 pd;
    f32 sx = self.skeleton.scaleX;
    f32 sy = self.skeleton.scaleY * cast(f32, spBone_isYDown() != 0 ? -1 : 1);
    spBone* parent = self.parent;
    self.ax = x;
    self.ay = y;
    self.arotation = rotation;
    self.ascaleX = scaleX;
    self.ascaleY = scaleY;
    self.ashearX = shearX;
    self.ashearY = shearY;
    if parent == null {
        f32 rx = (rotation + shearX) * (3.141592653589793f / 180.0f);
        f32 ry = (rotation + 90.0f + shearY) * (3.141592653589793f / 180.0f);
        self.a = cosf(rx) * scaleX * sx;
        self.b = cosf(ry) * scaleY * sx;
        self.c = sinf(rx) * scaleX * sy;
        self.d = sinf(ry) * scaleY * sy;
        self.worldX = x * sx + self.skeleton.x;
        self.worldY = y * sy + self.skeleton.y;
        return;
    }
    pa = parent.a;
    pb = parent.b;
    pc = parent.c;
    pd = parent.d;
    self.worldX = pa * x + pb * y + parent.worldX;
    self.worldY = pc * x + pd * y + parent.worldY;
    switch self.inherit {
        case SP_INHERIT_NORMAL: {
            {
                f32 rx = (rotation + shearX) * (3.141592653589793f / 180.0f);
                f32 ry = (rotation + 90.0f + shearY) * (3.141592653589793f / 180.0f);
                f32 la = cosf(rx) * scaleX;
                f32 lb = cosf(ry) * scaleY;
                f32 lc = sinf(rx) * scaleX;
                f32 ld = sinf(ry) * scaleY;
                self.a = pa * la + pb * lc;
                self.b = pa * lb + pb * ld;
                self.c = pc * la + pd * lc;
                self.d = pc * lb + pd * ld;
                return;
            }
        }
        case SP_INHERIT_ONLYTRANSLATION: {
            {
                f32 rx = (rotation + shearX) * (3.141592653589793f / 180.0f);
                f32 ry = (rotation + 90.0f + shearY) * (3.141592653589793f / 180.0f);
                self.a = cosf(rx) * scaleX;
                self.b = cosf(ry) * scaleY;
                self.c = sinf(rx) * scaleX;
                self.d = sinf(ry) * scaleY;
                break case;
            }
        }
        case SP_INHERIT_NOROTATIONORREFLECTION: {
            {
                f32 s = pa * pa + pc * pc;
                f32 prx;
                if s > 0.0001f {
                    s = (pa * pd - pb * pc < 0.0f ? -(pa * pd - pb * pc) : pa * pd - pb * pc) / s;
                    pa /= sx;
                    pc /= sy;
                    pb = pc * s;
                    pd = pa * s;
                    prx = atan2f(pc, pa) * (180.0f / 3.141592653589793f);
                } else {
                    pa = 0.0f;
                    pc = 0.0f;
                    prx = 90.0f - atan2f(pd, pb) * (180.0f / 3.141592653589793f);
                }
                f32 rx = (rotation + shearX - prx) * (3.141592653589793f / 180.0f);
                f32 ry = (rotation + shearY - prx + 90.0f) * (3.141592653589793f / 180.0f);
                f32 la = cosf(rx) * scaleX;
                f32 lb = cosf(ry) * scaleY;
                f32 lc = sinf(rx) * scaleX;
                f32 ld = sinf(ry) * scaleY;
                self.a = pa * la - pb * lc;
                self.b = pa * lb - pb * ld;
                self.c = pc * la + pd * lc;
                self.d = pc * lb + pd * ld;
                break case;
            }
        }
        case SP_INHERIT_NOSCALE, SP_INHERIT_NOSCALEORREFLECTION: {
            {
                rotation *= 3.141592653589793f / 180.0f;
                f32 cosine = cosf(rotation);
                f32 sine = sinf(rotation);
                f32 za = (pa * cosine + pb * sine) / sx;
                f32 zc = (pc * cosine + pd * sine) / sy;
                f32 s = sqrtf(za * za + zc * zc);
                if s > 1.0e-5f {
                    s = 1.0f / s;
                }
                za *= s;
                zc *= s;
                s = sqrtf(za * za + zc * zc);
                if self.inherit == SP_INHERIT_NOSCALE && pa * pd - pb * pc < 0.0f != (sx < 0.0f != sy < 0.0f) {
                    s = -s;
                }
                rotation = 3.141592653589793f / 2.0f + atan2f(zc, za);
                f32 zb = cosf(rotation) * s;
                f32 zd = sinf(rotation) * s;
                shearX *= 3.141592653589793f / 180.0f;
                shearY = (90.0f + shearY) * (3.141592653589793f / 180.0f);
                f32 la = cosf(shearX) * scaleX;
                f32 lb = cosf(shearY) * scaleY;
                f32 lc = sinf(shearX) * scaleX;
                f32 ld = sinf(shearY) * scaleY;
                self.a = za * la + zb * lc;
                self.b = za * lb + zb * ld;
                self.c = zc * la + zd * lc;
                self.d = zc * lb + zd * ld;
            }
        }
    }
    self.a *= sx;
    self.b *= sx;
    self.c *= sy;
    self.d *= sy;
}

void spBone_setToSetupPose(spBone* self) {
    self.x = self.data.x;
    self.y = self.data.y;
    self.rotation = self.data.rotation;
    self.scaleX = self.data.scaleX;
    self.scaleY = self.data.scaleY;
    self.shearX = self.data.shearX;
    self.shearY = self.data.shearY;
    self.inherit = self.data.inherit;
}

f32 spBone_getWorldRotationX(spBone* self) {
    return atan2f(self.c, self.a) * (180.0f / 3.141592653589793f);
}

f32 spBone_getWorldRotationY(spBone* self) {
    return atan2f(self.d, self.b) * (180.0f / 3.141592653589793f);
}

f32 spBone_getWorldScaleX(spBone* self) {
    return sqrtf(self.a * self.a + self.c * self.c);
}

f32 spBone_getWorldScaleY(spBone* self) {
    return sqrtf(self.b * self.b + self.d * self.d);
}

/** Computes the individual applied transform values from the world transform. This can be useful to perform processing using
 * the applied transform after the world transform has been modified directly (eg, by a constraint).
 * <p>
 * Some information is ambiguous in the world transform, such as -1,-1 scale versus 180 rotation. */
void spBone_updateAppliedTransform(spBone* self) {
    f32 pa;
    f32 pb;
    f32 pc;
    f32 pd;
    f32 pid;
    f32 ia;
    f32 ib;
    f32 ic;
    f32 id;
    f32 dx;
    f32 dy;
    f32 ra;
    f32 rb;
    f32 rc;
    f32 rd;
    f32 s;
    f32 sa;
    f32 sc;
    f32 cosine;
    f32 sine;
    var yDownScale = cast(f32, spBone_isYDown() != 0 ? -1 : 1);
    spBone* parent = self.parent;
    if parent == null {
        self.ax = self.worldX - self.skeleton.x;
        self.ay = self.worldY - self.skeleton.y;
        self.arotation = atan2f(self.c, self.a) * (180.0f / 3.141592653589793f);
        self.ascaleX = sqrtf(self.a * self.a + self.c * self.c);
        self.ascaleY = sqrtf(self.b * self.b + self.d * self.d);
        self.ashearX = 0.0f;
        self.ashearY = atan2f(self.a * self.b + self.c * self.d, self.a * self.d - self.b * self.c) * (180.0f / 3.141592653589793f);
        return;
    }
    pa = parent.a;
    pb = parent.b;
    pc = parent.c;
    pd = parent.d;
    pid = 1.0f / (pa * pd - pb * pc);
    ia = pd * pid;
    ib = pb * pid;
    ic = pc * pid;
    id = pa * pid;
    dx = self.worldX - parent.worldX;
    dy = self.worldY - parent.worldY;
    self.ax = dx * ia - dy * ib;
    self.ay = dy * id - dx * ic;
    if self.inherit == SP_INHERIT_ONLYTRANSLATION {
        ra = self.a;
        rb = self.b;
        rc = self.c;
        rd = self.d;
    } else {
        switch self.inherit {
            case SP_INHERIT_NOROTATIONORREFLECTION: {
                {
                    s = (pa * pd - pb * pc < 0.0f ? -(pa * pd - pb * pc) : pa * pd - pb * pc) / (pa * pa + pc * pc);
                    sa = pa / self.skeleton.scaleX;
                    sc = pc / self.skeleton.scaleY * yDownScale;
                    pb = -sc * s * self.skeleton.scaleX;
                    pd = sa * s * self.skeleton.scaleY * yDownScale;
                    pid = 1.0f / (pa * pd - pb * pc);
                    ia = pd * pid;
                    ib = pb * pid;
                    break case;
                }
            }
            case SP_INHERIT_NOSCALE, SP_INHERIT_NOSCALEORREFLECTION: {
                {
                    f32 r = self.rotation * (3.141592653589793f / 180.0f);
                    cosine = cosf(r);
                    sine = sinf(r);
                    pa = (pa * cosine + pb * sine) / self.skeleton.scaleX;
                    pc = (pc * cosine + pd * sine) / self.skeleton.scaleY * yDownScale;
                    s = sqrtf(pa * pa + pc * pc);
                    if s > 1.0e-5 {
                        s = 1.0f / s;
                    }
                    pa *= s;
                    pc *= s;
                    s = sqrtf(pa * pa + pc * pc);
                    if self.inherit == SP_INHERIT_NOSCALE && pid < 0.0f != (self.skeleton.scaleX < 0.0f != self.skeleton.scaleY * yDownScale < 0.0f) {
                        s = -s;
                    }
                    r = 3.141592653589793f / 2.0f + atan2f(pc, pa);
                    pb = cosf(r) * s;
                    pd = sinf(r) * s;
                    pid = 1.0f / (pa * pd - pb * pc);
                    ia = pd * pid;
                    ib = pb * pid;
                    ic = pc * pid;
                    id = pa * pid;
                    break case;
                }
            }
            case SP_INHERIT_ONLYTRANSLATION, SP_INHERIT_NORMAL: {
            }
        }
        ra = ia * self.a - ib * self.c;
        rb = ia * self.b - ib * self.d;
        rc = id * self.c - ic * self.a;
        rd = id * self.d - ic * self.b;
    }
    self.ashearX = 0.0f;
    self.ascaleX = sqrtf(ra * ra + rc * rc);
    if self.ascaleX > 0.0001f {
        f32 det = ra * rd - rb * rc;
        self.ascaleY = det / self.ascaleX;
        self.ashearY = -(atan2f(ra * rb + rc * rd, det) * (180.0f / 3.141592653589793f));
        self.arotation = atan2f(rc, ra) * (180.0f / 3.141592653589793f);
    } else {
        self.ascaleX = 0.0f;
        self.ascaleY = sqrtf(rb * rb + rd * rd);
        self.ashearY = 0.0f;
        self.arotation = 90.0f - atan2f(rd, rb) * (180.0f / 3.141592653589793f);
    }
}

void spBone_worldToLocal(spBone* self, f32 worldX, f32 worldY, f32* localX, f32* localY) {
    f32 invDet = 1.0f / (self.a * self.d - self.b * self.c);
    f32 x = worldX - self.worldX;
    f32 y = worldY - self.worldY;
    *localX = x * self.d * invDet - y * self.b * invDet;
    *localY = y * self.a * invDet - x * self.c * invDet;
}

void spBone_worldToParent(spBone* self, f32 worldX, f32 worldY, f32* localX, f32* localY) {
    if self.parent == null {
        *localX = worldX;
        *localY = worldY;
    } else {
        spBone_worldToLocal(self.parent, worldX, worldY, localX, localY);
    }
}

void spBone_localToWorld(spBone* self, f32 localX, f32 localY, f32* worldX, f32* worldY) {
    f32 x = localX;
    f32 y = localY;
    *worldX = x * self.a + y * self.b + self.worldX;
    *worldY = x * self.c + y * self.d + self.worldY;
}

void spBone_parentToWorld(spBone* self, f32 localX, f32 localY, f32* worldX, f32* worldY) {
    if self.parent == null {
        *worldX = localX;
        *worldY = localY;
    } else {
        spBone_localToWorld(self.parent, localX, localY, worldX, worldY);
    }
}

f32 spBone_worldToLocalRotation(spBone* self, f32 worldRotation) {
    worldRotation *= 3.141592653589793f / 180.0f;
    f32 sine = sinf(worldRotation);
    f32 cosine = cosf(worldRotation);
    return atan2f(self.a * sine - self.c * cosine, self.d * cosine - self.b * sine) * (180.0f / 3.141592653589793f) + self.rotation - self.shearX;
}

f32 spBone_localToWorldRotation(spBone* self, f32 localRotation) {
    localRotation = (localRotation - self.rotation - self.shearX) * (3.141592653589793f / 180.0f);
    f32 sine = sinf(localRotation);
    f32 cosine = cosf(localRotation);
    return atan2f(cosine * self.c + sine * self.d, cosine * self.a + sine * self.b) * (180.0f / 3.141592653589793f);
}

void spBone_rotateWorld(spBone* self, f32 degrees) {
    degrees *= 3.141592653589793f / 180.0f;
    f32 sine = sinf(degrees);
    f32 cosine = cosf(degrees);
    f32 ra = self.a;
    f32 rb = self.b;
    self.a = cosine * ra - sine * self.c;
    self.b = cosine * rb - sine * self.d;
    self.c = sine * ra + cosine * self.c;
    self.d = sine * rb + cosine * self.d;
}

spBoneData* spBoneData_create(i32 index, u8* name, spBoneData* parent) {
    var self = cast(spBoneData*, _spCalloc(1, cast(u64, sizeof(spBoneData)), "extension.h", 51));
    self.index = index;
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 51));
    strcpy(self.name, name);
    self.parent = parent;
    self.scaleX = 1.0f;
    self.scaleY = 1.0f;
    self.inherit = SP_INHERIT_NORMAL;
    self.icon = null;
    self.visible = -1;
    return self;
}

void spBoneData_dispose(spBoneData* self) {
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self.icon));
    _spFree(cast(void*, self));
}

void _spBoundingBoxAttachment_dispose(spAttachment* attachment) {
    var self = cast(spBoundingBoxAttachment*, attachment);
    _spVertexAttachment_deinit(&self.super);
    _spFree(cast(void*, self));
}

spAttachment* _spBoundingBoxAttachment_copy(spAttachment* attachment) {
    spBoundingBoxAttachment* copy = spBoundingBoxAttachment_create(attachment.name);
    var self = cast(spBoundingBoxAttachment*, attachment);
    spVertexAttachment_copyTo(&self.super, &copy.super);
    return &copy.super.super;
}

spBoundingBoxAttachment* spBoundingBoxAttachment_create(u8* name) {
    var self = cast(spBoundingBoxAttachment*, _spCalloc(1, cast(u64, sizeof(spBoundingBoxAttachment)), "extension.h", 55));
    _spVertexAttachment_init(&self.super);
    _spAttachment_init(&self.super.super, name, SP_ATTACHMENT_BOUNDING_BOX, cast(fn(spAttachment*): void, _spBoundingBoxAttachment_dispose), cast(fn(spAttachment*): spAttachment*, _spBoundingBoxAttachment_copy));
    return self;
}

void _spClippingAttachment_dispose(spAttachment* attachment) {
    var self = cast(spClippingAttachment*, attachment);
    _spVertexAttachment_deinit(&self.super);
    _spFree(cast(void*, self));
}

spAttachment* _spClippingAttachment_copy(spAttachment* attachment) {
    spClippingAttachment* copy = spClippingAttachment_create(attachment.name);
    var self = cast(spClippingAttachment*, attachment);
    spVertexAttachment_copyTo(&self.super, &copy.super);
    copy.endSlot = self.endSlot;
    return &copy.super.super;
}

spClippingAttachment* spClippingAttachment_create(u8* name) {
    var self = cast(spClippingAttachment*, _spCalloc(1, cast(u64, sizeof(spClippingAttachment)), "extension.h", 57));
    _spVertexAttachment_init(&self.super);
    _spAttachment_init(&self.super.super, name, SP_ATTACHMENT_CLIPPING, cast(fn(spAttachment*): void, _spClippingAttachment_dispose), cast(fn(spAttachment*): spAttachment*, _spClippingAttachment_copy));
    self.endSlot = null;
    return self;
}

spColor* spColor_create() {
    return cast(spColor*, _spMalloc(cast(u64, sizeof(spColor) * 1), "extension.h", 109));
}

void spColor_dispose(spColor* self) {
    if self != null {
        _spFree(cast(void*, self));
    }
}

void spColor_setFromFloats(spColor* self, f32 r, f32 g, f32 b, f32 a) {
    self.r = r;
    self.g = g;
    self.b = b;
    self.a = a;
    spColor_clamp(self);
}

void spColor_setFromFloats3(spColor* self, f32 r, f32 g, f32 b) {
    self.r = r;
    self.g = g;
    self.b = b;
    spColor_clamp(self);
}

void spColor_setFromColor(spColor* self, spColor* otherColor) {
    self.r = otherColor.r;
    self.g = otherColor.g;
    self.b = otherColor.b;
    self.a = otherColor.a;
}

void spColor_setFromColor3(spColor* self, spColor* otherColor) {
    self.r = otherColor.r;
    self.g = otherColor.g;
    self.b = otherColor.b;
}

void spColor_addColor(spColor* self, spColor* otherColor) {
    self.r += otherColor.r;
    self.g += otherColor.g;
    self.b += otherColor.b;
    self.a += otherColor.a;
    spColor_clamp(self);
}

void spColor_addFloats(spColor* self, f32 r, f32 g, f32 b, f32 a) {
    self.r += r;
    self.g += g;
    self.b += b;
    self.a += a;
    spColor_clamp(self);
}

void spColor_addFloats3(spColor* self, f32 r, f32 g, f32 b) {
    self.r += r;
    self.g += g;
    self.b += b;
    spColor_clamp(self);
}

void spColor_clamp(spColor* self) {
    if self.r < 0.0f {
        self.r = 0.0f;
    } else if self.r > 1.0f {
        self.r = 1.0f;
    }
    if self.g < 0.0f {
        self.g = 0.0f;
    } else if self.g > 1.0f {
        self.g = 1.0f;
    }
    if self.b < 0.0f {
        self.b = 0.0f;
    } else if self.b > 1.0f {
        self.b = 1.0f;
    }
    if self.a < 0.0f {
        self.a = 0.0f;
    } else if self.a > 1.0f {
        self.a = 1.0f;
    }
}

spEvent* spEvent_create(f32 time, spEventData* data) {
    var self = cast(spEvent*, _spCalloc(1, cast(u64, sizeof(spEvent)), "extension.h", 44));
    self.data = data;
    self.time = time;
    return self;
}

void spEvent_dispose(spEvent* self) {
    _spFree(cast(void*, self.stringValue));
    _spFree(cast(void*, self));
}

spEventData* spEventData_create(u8* name) {
    var self = cast(spEventData*, _spCalloc(1, cast(u64, sizeof(spEventData)), "extension.h", 45));
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 45));
    strcpy(self.name, name);
    return self;
}

void spEventData_dispose(spEventData* self) {
    _spFree(cast(void*, self.audioPath));
    _spFree(cast(void*, self.stringValue));
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self));
}

spIkConstraint* spIkConstraint_create(spIkConstraintData* data, spSkeleton* skeleton) {
    i32 i;
    var self = cast(spIkConstraint*, _spCalloc(1, cast(u64, sizeof(spIkConstraint)), "extension.h", 86));
    self.data = data;
    self.bendDirection = data.bendDirection;
    self.compress = data.compress;
    self.stretch = data.stretch;
    self.mix = data.mix;
    self.softness = data.softness;
    self.bonesCount = self.data.bonesCount;
    self.bones = cast(spBone**, _spMalloc(cast(u64, sizeof(spBone*) * self.bonesCount), "extension.h", 83));
    for i = 0; i < self.bonesCount; ++i {
        self.bones[i] = spSkeleton_findBone(skeleton, self.data.bones[i].name);
    }
    self.target = spSkeleton_findBone(skeleton, self.data.target.name);
    return self;
}

void spIkConstraint_dispose(spIkConstraint* self) {
    _spFree(cast(void*, self.bones));
    _spFree(cast(void*, self));
}

void spIkConstraint_update(spIkConstraint* self) {
    if self.mix == 0.0f {
        return;
    }
    switch self.bonesCount {
        case 1: {
            spIkConstraint_apply1(self.bones[0], self.target.worldX, self.target.worldY, self.compress, self.stretch, self.data.uniform, self.mix);
        }
        case 2: {
            spIkConstraint_apply2(self.bones[0], self.bones[1], self.target.worldX, self.target.worldY, self.bendDirection, self.stretch, self.data.uniform, self.softness, self.mix);
        }
    }
}

void spIkConstraint_setToSetupPose(spIkConstraint* self) {
    self.bendDirection = self.data.bendDirection;
    self.compress = self.data.compress;
    self.stretch = self.data.stretch;
    self.softness = self.data.softness;
    self.mix = self.data.mix;
}

void spIkConstraint_apply1(spBone* bone, f32 targetX, f32 targetY, i32 compress, i32 stretch, i32 uniform, f32 alpha) {
    spBone* p = bone.parent;
    f32 pa = p.a;
    f32 pb = p.b;
    f32 pc = p.c;
    f32 pd = p.d;
    f32 rotationIK = -bone.ashearX - bone.arotation;
    f32 tx = 0.0f;
    f32 ty = 0.0f;
    f32 sx = 0.0f;
    f32 sy = 0.0f;
    f32 s = 0.0f;
    f32 sa = 0.0f;
    f32 sc = 0.0f;
    switch bone.data.inherit {
        case SP_INHERIT_ONLYTRANSLATION: {
            tx = (targetX - bone.worldX) * (bone.skeleton.scaleX < 0.0f ? -1.0f : bone.skeleton.scaleX > 0.0f ? 1.0f : 0.0f);
            ty = (targetY - bone.worldY) * (bone.skeleton.scaleY < 0.0f ? -1.0f : bone.skeleton.scaleY > 0.0f ? 1.0f : 0.0f);
        }
        case SP_INHERIT_NOROTATIONORREFLECTION: {
            {
                s = (pa * pd - pb * pc < 0.0f ? -(pa * pd - pb * pc) : pa * pd - pb * pc) / (0.0001f > pa * pa + pc * pc ? 0.0001f : pa * pa + pc * pc);
                sa = pa / bone.skeleton.scaleX;
                sc = pc / bone.skeleton.scaleY;
                pb = -sc * s * bone.skeleton.scaleX;
                pd = sa * s * bone.skeleton.scaleY;
                rotationIK += atan2f(sc, sa) * (180.0f / 3.141592653589793f);
            }
            fallthrough;
        }
        default: {
            {
                f32 x = targetX - p.worldX;
                f32 y = targetY - p.worldY;
                f32 d = pa * pd - pb * pc;
                if (d < 0.0f ? -d : d) <= 0.0001f {
                    tx = 0.0f;
                    ty = 0.0f;
                } else {
                    tx = (x * pd - y * pb) / d - bone.ax;
                    ty = (y * pa - x * pc) / d - bone.ay;
                }
            }
        }
    }
    rotationIK += atan2f(ty, tx) * (180.0f / 3.141592653589793f);
    if bone.ascaleX < 0.0f {
        rotationIK += 180.0f;
    }
    if rotationIK > 180.0f {
        rotationIK -= 360.0f;
    } else if rotationIK < -180.0f {
        rotationIK += 360.0f;
    }
    sx = bone.ascaleX;
    sy = bone.ascaleY;
    if compress || stretch {
        f32 b;
        f32 dd;
        switch bone.data.inherit {
            case SP_INHERIT_NOSCALE, SP_INHERIT_NOSCALEORREFLECTION: {
                tx = targetX - bone.worldX;
                ty = targetY - bone.worldY;
                fallthrough;
            }
            default: {
            }
        }
        b = bone.data.length * sx;
        dd = sqrtf(tx * tx + ty * ty);
        if compress && dd < b || stretch && dd > b && b > 0.0001f {
            s = (dd / b - 1.0f) * alpha + 1.0f;
            sx *= s;
            if uniform != 0 {
                sy *= s;
            }
        }
    }
    spBone_updateWorldTransformWith(bone, bone.ax, bone.ay, bone.arotation + rotationIK * alpha, sx, sy, bone.ashearX, bone.ashearY);
}

void spIkConstraint_apply2(spBone* parent, spBone* child, f32 targetX, f32 targetY, i32 bendDir, i32 stretch, i32 uniform, f32 softness, f32 alpha) {
    f32 a;
    f32 b;
    f32 c;
    f32 d;
    f32 px;
    f32 py;
    f32 psx;
    f32 psy;
    f32 sx;
    f32 sy;
    f32 cx;
    f32 cy;
    f32 csx;
    f32 cwx;
    f32 cwy;
    i32 o1;
    i32 o2;
    i32 s2;
    i32 u;
    spBone* pp = parent.parent;
    f32 tx;
    f32 ty;
    f32 dd;
    f32 dx;
    f32 dy;
    f32 l1;
    f32 l2;
    f32 a1;
    f32 a2;
    f32 r;
    f32 td;
    f32 sd;
    f32 p;
    f32 id;
    f32 x;
    f32 y;
    f32 aa;
    f32 bb;
    f32 ll;
    f32 ta;
    f32 c0;
    f32 c1;
    f32 c2;
    px = parent.ax;
    py = parent.ay;
    psx = parent.ascaleX;
    psy = parent.ascaleY;
    sx = psx;
    sy = psy;
    csx = child.ascaleX;
    if psx < 0.0f {
        psx = -psx;
        o1 = 180;
        s2 = -1;
    } else {
        o1 = 0;
        s2 = 1;
    }
    if psy < 0.0f {
        psy = -psy;
        s2 = -s2;
    }
    if csx < 0.0f {
        csx = -csx;
        o2 = 180;
    } else {
        o2 = 0;
    }
    r = psx - psy;
    cx = child.ax;
    u = (r < 0.0f ? -r : r) <= 0.0001f;
    if !u || stretch {
        cy = 0.0f;
        cwx = parent.a * cx + parent.worldX;
        cwy = parent.c * cx + parent.worldY;
    } else {
        cy = child.ay;
        cwx = parent.a * cx + parent.b * cy + parent.worldX;
        cwy = parent.c * cx + parent.d * cy + parent.worldY;
    }
    a = pp.a;
    b = pp.b;
    c = pp.c;
    d = pp.d;
    id = a * d - b * c;
    id = cast(f32, (id < 0.0f ? -id : id) <= 0.0001f ? 0.0f : 1.0f / id);
    x = cwx - pp.worldX;
    y = cwy - pp.worldY;
    dx = (x * d - y * b) * id - px;
    dy = (y * a - x * c) * id - py;
    l1 = sqrtf(dx * dx + dy * dy);
    l2 = child.data.length * csx;
    if l1 < 0.0001 {
        spIkConstraint_apply1(parent, targetX, targetY, 0, stretch, 0, alpha);
        spBone_updateWorldTransformWith(child, cx, cy, 0.0f, child.ascaleX, child.ascaleY, child.ashearX, child.ashearY);
        return;
    }
    x = targetX - pp.worldX;
    y = targetY - pp.worldY;
    tx = (x * d - y * b) * id - px;
    ty = (y * a - x * c) * id - py;
    dd = tx * tx + ty * ty;
    if softness != 0.0f {
        softness *= psx * (csx + 1.0f) * 0.5f;
        td = sqrtf(dd);
        sd = td - l1 - l2 * psx + softness;
        if sd > 0.0f {
            p = cast(f32, (1.0f < sd / (softness * 2.0f) ? 1.0f : sd / (softness * 2.0f)) - 1);
            p = (sd - softness * (1.0f - p * p)) / td;
            tx -= p * tx;
            ty -= p * ty;
            dd = tx * tx + ty * ty;
        }
    }
    if u != 0 {
        f32 cosine;
        l2 *= psx;
        cosine = (dd - l1 * l1 - l2 * l2) / (2.0f * l1 * l2);
        if cosine < -1.0f {
            cosine = cast(f32, -1);
            a2 = 3.141592653589793f * cast(f32, bendDir);
        } else if cosine > 1.0f {
            cosine = 1.0f;
            a2 = 0.0f;
            if stretch != 0 {
                a = (sqrtf(dd) / (l1 + l2) - 1.0f) * alpha + 1.0f;
                sx *= a;
                if uniform != 0 {
                    sy *= a;
                }
            }
        } else {
            a2 = acosf(cosine) * cast(f32, bendDir);
        }
        a = l1 + l2 * cosine;
        b = l2 * sinf(a2);
        a1 = atan2f(ty * a - tx * b, tx * a + ty * b);
    } else {
        a = psx * l2;
        b = psy * l2;
        aa = a * a;
        bb = b * b;
        ll = l1 * l1;
        ta = atan2f(ty, tx);
        c0 = bb * ll + aa * dd - aa * bb;
        c1 = -2.0f * bb * l1;
        c2 = bb - aa;
        d = c1 * c1 - 4.0f * c2 * c0;
        if d >= 0.0f {
            f32 q = sqrtf(d);
            f32 r0;
            f32 r1;
            if c1 < 0.0f {
                q = -q;
            }
            q = -(c1 + q) * 0.5f;
            r0 = q / c2;
            r1 = c0 / q;
            r = (r0 < 0.0f ? -r0 : r0) < (r1 < 0.0f ? -r1 : r1) ? r0 : r1;
            y = dd - r * r;
            if y > 0.0f {
                y = sqrtf(y) * cast(f32, bendDir);
                a1 = ta - atan2f(y, r);
                a2 = atan2f(y / psy, (r - l1) / psx);
                {
                    {
                        f32 os = atan2f(cy, cx) * cast(f32, s2);
                        f32 rotation = parent.arotation;
                        a1 = (a1 - os) * (180.0f / 3.141592653589793f) + cast(f32, o1) - rotation;
                        if a1 > 180.0f {
                            a1 -= 360.0f;
                        } else if a1 < -180.0f {
                            a1 += 360.0f;
                        }
                        spBone_updateWorldTransformWith(parent, px, py, rotation + a1 * alpha, sx, sy, 0.0f, 0.0f);
                        rotation = child.arotation;
                        a2 = ((a2 + os) * (180.0f / 3.141592653589793f) - child.ashearX) * cast(f32, s2) + cast(f32, o2) - rotation;
                        if a2 > 180.0f {
                            a2 -= 360.0f;
                        } else if a2 < -180.0f {
                            a2 += 360.0f;
                        }
                        spBone_updateWorldTransformWith(child, cx, cy, rotation + a2 * alpha, child.ascaleX, child.ascaleY, child.ashearX, child.ashearY);
                    }
                    return;
                }
            }
        }
        {
            f32 minAngle = 3.141592653589793f;
            f32 minX = l1 - a;
            f32 minDist = minX * minX;
            f32 minY = 0.0f;
            f32 maxAngle = 0.0f;
            f32 maxX = l1 + a;
            f32 maxDist = maxX * maxX;
            f32 maxY = 0.0f;
            c0 = -a * l1 / (aa - bb);
            if c0 >= -1.0f && c0 <= 1.0f {
                c0 = acosf(c0);
                x = a * cosf(c0) + l1;
                y = b * sinf(c0);
                d = x * x + y * y;
                if d < minDist {
                    minAngle = c0;
                    minDist = d;
                    minX = x;
                    minY = y;
                }
                if d > maxDist {
                    maxAngle = c0;
                    maxDist = d;
                    maxX = x;
                    maxY = y;
                }
            }
            if dd <= (minDist + maxDist) * 0.5f {
                a1 = ta - atan2f(minY * cast(f32, bendDir), minX);
                a2 = minAngle * cast(f32, bendDir);
            } else {
                a1 = ta - atan2f(maxY * cast(f32, bendDir), maxX);
                a2 = maxAngle * cast(f32, bendDir);
            }
        }
    }
    {
        f32 os = atan2f(cy, cx) * cast(f32, s2);
        f32 rotation = parent.arotation;
        a1 = (a1 - os) * (180.0f / 3.141592653589793f) + cast(f32, o1) - rotation;
        if a1 > 180.0f {
            a1 -= 360.0f;
        } else if a1 < -180.0f {
            a1 += 360.0f;
        }
        spBone_updateWorldTransformWith(parent, px, py, rotation + a1 * alpha, sx, sy, 0.0f, 0.0f);
        rotation = child.arotation;
        a2 = ((a2 + os) * (180.0f / 3.141592653589793f) - child.ashearX) * cast(f32, s2) + cast(f32, o2) - rotation;
        if a2 > 180.0f {
            a2 -= 360.0f;
        } else if a2 < -180.0f {
            a2 += 360.0f;
        }
        spBone_updateWorldTransformWith(child, cx, cy, rotation + a2 * alpha, child.ascaleX, child.ascaleY, child.ashearX, child.ashearY);
    }
    return;
}

spIkConstraintData* spIkConstraintData_create(u8* name) {
    var self = cast(spIkConstraintData*, _spCalloc(1, cast(u64, sizeof(spIkConstraintData)), "extension.h", 49));
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 49));
    strcpy(self.name, name);
    self.bendDirection = 0;
    self.compress = 0;
    self.stretch = 0;
    self.uniform = 0;
    self.mix = 0.0f;
    return self;
}

void spIkConstraintData_dispose(spIkConstraintData* self) {
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self.bones));
    _spFree(cast(void*, self));
}
/*
 Copyright (c) 2009 Dave Gamble

 Permission is hereby granted, dispose of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
/* Esoteric Software: Removed everything except parsing, shorter method names, more get methods, double to float, formatted. */
/* Json Types: */
private { u8* ep; }

u8* Json_getError() {
    return ep;
}

private {
i32 Json_strcasecmp(u8* s1, u8* s2) {
    if s1 && s2 {
        return _stricmp(s1, s2);
    } else {
        if s1 < s2 {
            return -1;
        } else if s1 == s2 {
            return 0;
        } else {
            return 1;
        }
    }
}

/* Internal constructor. */
Json* Json_new() {
    return cast(Json*, _spCalloc(1, cast(u64, sizeof(Json)), "extension.h", 140));
}
}

/* Delete a Json structure. */
void Json_dispose(Json* c) {
    Json* next;
    while c != null {
        next = c.next;
        if c.child != null {
            Json_dispose(c.child);
        }
        if c.valueString != null {
            _spFree(cast(void*, c.valueString));
        }
        if c.name != null {
            _spFree(cast(void*, c.name));
        }
        _spFree(cast(void*, c));
        c = next;
    }
}

/* Parse the input text to generate a number, and populate the result into item. */
private {
u8* parse_number(Json* item, u8* num) {
    f64 result = 0.0;
    i32 negative = 0;
    var ptr = num;
    if *ptr == 45 {
        negative = -1;
        ++ptr;
    }
    while *ptr >= 48 && *ptr <= 57 {
        result = result * 10.0 + cast(f64, *ptr - 48);
        ++ptr;
    }
    if *ptr == 46 {
        f64 fraction = 0.0;
        i32 n = 0;
        ++ptr;
        while *ptr >= 48 && *ptr <= 57 {
            fraction = fraction * 10.0 + cast(f64, *ptr - 48);
            ++ptr;
            ++n;
        }
        result += fraction / pow(10.0, cast(f64, n));
    }
    if negative != 0 {
        result = -result;
    }
    if *ptr == 101 || *ptr == 69 {
        f64 exponent = 0.0;
        i32 expNegative = 0;
        ++ptr;
        if *ptr == 45 {
            expNegative = -1;
            ++ptr;
        } else if *ptr == 43 {
            ++ptr;
        }
        while *ptr >= 48 && *ptr <= 57 {
            exponent = exponent * 10.0 + cast(f64, *ptr - 48);
            ++ptr;
        }
        if expNegative != 0 {
            result = result / pow(10.0, exponent);
        } else {
            result = result * pow(10.0, exponent);
        }
    }
    if ptr != num {
        item.valueFloat = cast(f32, result);
        item.valueInt = cast(i32, result);
        item.type = 3;
        return ptr;
    } else {
        ep = num;
        return null;
    }
}
/* Parse the input text into an unescaped cstring, and populate item. */
u8[7] firstByteMark = {0x00, 0x00, 0xC0, 0xE0, 0xF0, 0xF8, 0xFC};

u8* parse_string(Json* item, u8* str_var) {
    u8* ptr = str_var + 1;
    u8* ptr2;
    u8* out;
    i32 len = 0;
    u32 uc;
    u32 uc2;
    if *str_var != 34 {
        ep = str_var;
        return null;
    }
    while *ptr != 34 && *ptr && ++len {
        if *ptr++ == 92 {
            ptr++;
        }
    }
    out = cast(u8*, _spMalloc(cast(u64, sizeof(u8) * (len + 1)), "extension.h", 135));
    if out == null {
        return null;
    }
    ptr = str_var + 1;
    ptr2 = out;
    while *ptr != 34 && *ptr {
        if *ptr != 92 {
            *ptr2++ = *ptr++;
        } else {
            ptr++;
            switch *ptr {
                case 98: {
                    *ptr2++ = 8;
                }
                case 102: {
                    *ptr2++ = 12;
                }
                case 110: {
                    *ptr2++ = 10;
                }
                case 114: {
                    *ptr2++ = 13;
                }
                case 116: {
                    *ptr2++ = 9;
                }
                case 117: {
                    _sp_scan4x(ptr + 1, &uc);
                    ptr += 4;
                    if uc >= 0xDC00 && uc <= 0xDFFF || uc == 0 {
                        break;
                    }
                    if uc >= 0xD800 && uc <= 0xDBFF {
                        if ptr[1] != 92 || ptr[2] != 117 {
                            break;
                        }
                        _sp_scan4x(ptr + 3, &uc2);
                        ptr += 6;
                        if uc2 < 0xDC00 || uc2 > 0xDFFF {
                            break;
                        }
                        uc = 0x10000 + ((uc & 0x3FF) << 10 | uc2 & 0x3FF);
                    }
                    len = 4;
                    if uc < 0x80 {
                        len = 1;
                    } else if uc < 0x800 {
                        len = 2;
                    } else if uc < 0x10000 {
                        len = 3;
                    }
                    ptr2 += len;
                    switch len {
                        case 4: {
                            *--ptr2 = cast(u8, (uc | 0x80) & 0xBF);
                            uc >>= 6;
                            fallthrough;
                        }
                        case 3: {
                            *--ptr2 = cast(u8, (uc | 0x80) & 0xBF);
                            uc >>= 6;
                            fallthrough;
                        }
                        case 2: {
                            *--ptr2 = cast(u8, (uc | 0x80) & 0xBF);
                            uc >>= 6;
                            fallthrough;
                        }
                        case 1: {
                            *--ptr2 = cast(u8, uc | firstByteMark[len]);
                        }
                    }
                    ptr2 += len;
                }
                default: {
                    *ptr2++ = *ptr;
                }
            }
            ptr++;
        }
    }
    *ptr2 = 0;
    if *ptr == 34 {
        ptr++;
    }
    item.valueString = out;
    item.type = 4;
    return ptr;
}
}

/* Utility to jump whitespace and cr/lf */
private {
u8* skip(u8* in) {
    if in == null {
        return null;
    }
    while *in && cast(u8, *in) <= 32 {
        in++;
    }
    return in;
}
}

/* Parse an object - create a new root, and populate. */
Json* Json_create(u8* value) {
    Json* c;
    ep = null;
    if value == null {
        return null;
    }
    c = Json_new();
    if c == null {
        return null;
    }
    value = parse_value(c, skip(value));
    if value == null {
        Json_dispose(c);
        return null;
    }
    return c;
}

/* Parser core - when encountering text, process appropriately. */
private {
u8* parse_value(Json* item, u8* value) {
    switch *value {
        case 110: {
            {
                if strncmp(value + 1, "ull", cast(u64, 3)) == 0 {
                    item.type = 2;
                    return value + 4;
                }
                break case;
            }
        }
        case 102: {
            {
                if strncmp(value + 1, "alse", cast(u64, 4)) == 0 {
                    item.type = 0;
                    return value + 5;
                }
                break case;
            }
        }
        case 116: {
            {
                if strncmp(value + 1, "rue", cast(u64, 3)) == 0 {
                    item.type = 1;
                    item.valueInt = 1;
                    return value + 4;
                }
                break case;
            }
        }
        case 34: {
            return parse_string(item, value);
        }
        case 91: {
            return parse_array(item, value);
        }
        case 123: {
            return parse_object(item, value);
        }
        case 45, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57: {
            return parse_number(item, value);
        }
        default: {
        }
    }
    ep = value;
    return null;
}

/* Build an array from input text. */
u8* parse_array(Json* item, u8* value) {
    Json* child;
    item.type = 5;
    value = skip(value + 1);
    if *value == 93 {
        return value + 1;
    }
    child = Json_new();
    item.child = child;
    if item.child == null {
        return null;
    }
    value = skip(parse_value(child, skip(value)));
    if value == null {
        return null;
    }
    item.size = 1;
    while *value == 44 {
        Json* new_item = Json_new();
        if new_item == null {
            return null;
        }
        child.next = new_item;
        child = new_item;
        value = skip(parse_value(child, skip(value + 1)));
        if value == null {
            return null;
        }
        item.size++;
    }
    if *value == 93 {
        return value + 1;
    }
    ep = value;
    return null;
}

/* Build an object from the text. */
u8* parse_object(Json* item, u8* value) {
    Json* child;
    item.type = 6;
    value = skip(value + 1);
    if *value == 125 {
        return value + 1;
    }
    child = Json_new();
    item.child = child;
    if item.child == null {
        return null;
    }
    value = skip(parse_string(child, skip(value)));
    if value == null {
        return null;
    }
    child.name = child.valueString;
    child.valueString = null;
    if *value != 58 {
        ep = value;
        return null;
    }
    value = skip(parse_value(child, skip(value + 1)));
    if value == null {
        return null;
    }
    item.size = 1;
    while *value == 44 {
        Json* new_item = Json_new();
        if new_item == null {
            return null;
        }
        child.next = new_item;
        child = new_item;
        value = skip(parse_string(child, skip(value + 1)));
        if value == null {
            return null;
        }
        child.name = child.valueString;
        child.valueString = null;
        if *value != 58 {
            ep = value;
            return null;
        }
        value = skip(parse_value(child, skip(value + 1)));
        if value == null {
            return null;
        }
        item.size++;
    }
    if *value == 125 {
        return value + 1;
    }
    ep = value;
    return null;
}
}

Json* Json_getItem(Json* object, u8* string_var) {
    Json* c = object.child;
    while c && Json_strcasecmp(c.name, string_var) {
        c = c.next;
    }
    return c;
}

Json* Json_getItemAtIndex(Json* object, i32 childIndex) {
    Json* current = object.child;
    while current != null && childIndex > 0 {
        childIndex--;
        current = current.next;
    }
    return current;
}

u8* Json_getString(Json* object, u8* name, u8* defaultValue) {
    object = Json_getItem(object, name);
    if object != null {
        return object.valueString;
    }
    return defaultValue;
}

f32 Json_getFloat(Json* value, u8* name, f32 defaultValue) {
    value = Json_getItem(value, name);
    return value != null ? value.valueFloat : defaultValue;
}

i32 Json_getInt(Json* value, u8* name, i32 defaultValue) {
    value = Json_getItem(value, name);
    return value != null ? value.valueInt : defaultValue;
}

void _spMeshAttachment_dispose(spAttachment* attachment) {
    var self = cast(spMeshAttachment*, attachment);
    if self.sequence != null {
        spSequence_dispose(self.sequence);
    }
    _spFree(cast(void*, self.path));
    _spFree(cast(void*, self.uvs));
    if self.parentMesh == null {
        _spVertexAttachment_deinit(&self.super);
        _spFree(cast(void*, self.regionUVs));
        _spFree(cast(void*, self.triangles));
        _spFree(cast(void*, self.edges));
    } else {
        _spAttachment_deinit(attachment);
    }
    _spFree(cast(void*, self));
}

spAttachment* _spMeshAttachment_copy(spAttachment* attachment) {
    spMeshAttachment* copy;
    var self = cast(spMeshAttachment*, attachment);
    if self.parentMesh != null {
        return &spMeshAttachment_newLinkedMesh(self).super.super;
    }
    copy = spMeshAttachment_create(attachment.name);
    copy.rendererObject = self.rendererObject;
    copy.region = self.region;
    copy.sequence = self.sequence != null ? spSequence_copy(self.sequence) : null;
    copy.path = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(self.path) + 1), "extension.h", 73));
    strcpy(copy.path, self.path);
    spColor_setFromColor(&copy.color, &self.color);
    spVertexAttachment_copyTo(&self.super, &copy.super);
    copy.regionUVs = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * self.super.worldVerticesLength), "extension.h", 73));
    memcpy(copy.regionUVs, self.regionUVs, cast(u64, self.super.worldVerticesLength * sizeof(f32)));
    copy.uvs = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * self.super.worldVerticesLength), "extension.h", 73));
    memcpy(copy.uvs, self.uvs, cast(u64, self.super.worldVerticesLength * sizeof(f32)));
    copy.trianglesCount = self.trianglesCount;
    copy.triangles = cast(u16*, _spMalloc(cast(u64, sizeof(u16) * self.trianglesCount), "extension.h", 73));
    memcpy(copy.triangles, self.triangles, cast(u64, self.trianglesCount * sizeof(i16)));
    copy.hullLength = self.hullLength;
    if self.edgesCount > 0 {
        copy.edgesCount = self.edgesCount;
        copy.edges = cast(u16*, _spMalloc(cast(u64, sizeof(u16) * self.edgesCount), "extension.h", 73));
        memcpy(copy.edges, self.edges, cast(u64, self.edgesCount * sizeof(i32)));
    }
    copy.width = self.width;
    copy.height = self.height;
    return &copy.super.super;
}

spMeshAttachment* spMeshAttachment_newLinkedMesh(spMeshAttachment* self) {
    spMeshAttachment* copy = spMeshAttachment_create(self.super.super.name);
    copy.rendererObject = self.rendererObject;
    copy.region = self.region;
    copy.path = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(self.path) + 1), "extension.h", 73));
    strcpy(copy.path, self.path);
    spColor_setFromColor(&copy.color, &self.color);
    copy.super.timelineAttachment = self.super.timelineAttachment;
    spMeshAttachment_setParentMesh(copy, self.parentMesh != null ? self.parentMesh : self);
    if copy.region != null {
        spMeshAttachment_updateRegion(copy);
    }
    return copy;
}

spMeshAttachment* spMeshAttachment_create(u8* name) {
    var self = cast(spMeshAttachment*, _spCalloc(1, cast(u64, sizeof(spMeshAttachment)), "extension.h", 76));
    _spVertexAttachment_init(&self.super);
    spColor_setFromFloats(&self.color, 1.0f, 1.0f, 1.0f, 1.0f);
    _spAttachment_init(&self.super.super, name, SP_ATTACHMENT_MESH, cast(fn(spAttachment*): void, _spMeshAttachment_dispose), cast(fn(spAttachment*): spAttachment*, _spMeshAttachment_copy));
    return self;
}

void spMeshAttachment_updateRegion(spMeshAttachment* self) {
    i32 i;
    i32 n;
    f32* uvs;
    f32 u;
    f32 v;
    f32 width;
    f32 height;
    i32 verticesLength = self.super.worldVerticesLength;
    _spFree(cast(void*, self.uvs));
    self.uvs = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * verticesLength), "extension.h", 73));
    uvs = self.uvs;
    n = verticesLength;
    u = self.region.u;
    v = self.region.v;
    switch self.region.degrees {
        case 90: {
            {
                f32 textureWidth = cast(f32, self.region.height) / (self.region.u2 - self.region.u);
                f32 textureHeight = cast(f32, self.region.width) / (self.region.v2 - self.region.v);
                u -= (cast(f32, self.region.originalHeight) - self.region.offsetY - cast(f32, self.region.height)) / textureWidth;
                v -= (cast(f32, self.region.originalWidth) - self.region.offsetX - cast(f32, self.region.width)) / textureHeight;
                width = cast(f32, self.region.originalHeight) / textureWidth;
                height = cast(f32, self.region.originalWidth) / textureHeight;
                for i = 0; i < n; i += 2 {
                    uvs[i] = u + self.regionUVs[i + 1] * width;
                    uvs[i + 1] = v + (1.0f - self.regionUVs[i]) * height;
                }
                return;
            }
        }
        case 180: {
            {
                f32 textureWidth = cast(f32, self.region.width) / (self.region.u2 - self.region.u);
                f32 textureHeight = cast(f32, self.region.height) / (self.region.v2 - self.region.v);
                u -= (cast(f32, self.region.originalWidth) - self.region.offsetX - cast(f32, self.region.width)) / textureWidth;
                v -= self.region.offsetY / textureHeight;
                width = cast(f32, self.region.originalWidth) / textureWidth;
                height = cast(f32, self.region.originalHeight) / textureHeight;
                for i = 0; i < n; i += 2 {
                    uvs[i] = u + (1.0f - self.regionUVs[i]) * width;
                    uvs[i + 1] = v + (1.0f - self.regionUVs[i + 1]) * height;
                }
                return;
            }
        }
        case 270: {
            {
                f32 textureHeight = cast(f32, self.region.height) / (self.region.v2 - self.region.v);
                f32 textureWidth = cast(f32, self.region.width) / (self.region.u2 - self.region.u);
                u -= self.region.offsetY / textureWidth;
                v -= self.region.offsetX / textureHeight;
                width = cast(f32, self.region.originalHeight) / textureWidth;
                height = cast(f32, self.region.originalWidth) / textureHeight;
                for i = 0; i < n; i += 2 {
                    uvs[i] = u + (1.0f - self.regionUVs[i + 1]) * width;
                    uvs[i + 1] = v + self.regionUVs[i] * height;
                }
                return;
            }
        }
        default: {
            {
                f32 textureWidth = cast(f32, self.region.width) / (self.region.u2 - self.region.u);
                f32 textureHeight = cast(f32, self.region.height) / (self.region.v2 - self.region.v);
                u -= self.region.offsetX / textureWidth;
                v -= (cast(f32, self.region.originalHeight) - self.region.offsetY - cast(f32, self.region.height)) / textureHeight;
                width = cast(f32, self.region.originalWidth) / textureWidth;
                height = cast(f32, self.region.originalHeight) / textureHeight;
                for i = 0; i < n; i += 2 {
                    uvs[i] = u + self.regionUVs[i] * width;
                    uvs[i + 1] = v + self.regionUVs[i + 1] * height;
                }
            }
        }
    }
}

void spMeshAttachment_setParentMesh(spMeshAttachment* self, spMeshAttachment* parentMesh) {
    self.parentMesh = parentMesh;
    if parentMesh != null {
        self.super.bones = parentMesh.super.bones;
        self.super.bonesCount = parentMesh.super.bonesCount;
        self.super.vertices = parentMesh.super.vertices;
        self.super.verticesCount = parentMesh.super.verticesCount;
        self.regionUVs = parentMesh.regionUVs;
        self.triangles = parentMesh.triangles;
        self.trianglesCount = parentMesh.trianglesCount;
        self.hullLength = parentMesh.hullLength;
        self.super.worldVerticesLength = parentMesh.super.worldVerticesLength;
        self.edges = parentMesh.edges;
        self.edgesCount = parentMesh.edgesCount;
        self.width = parentMesh.width;
        self.height = parentMesh.height;
    }
}

void _spPathAttachment_dispose(spAttachment* attachment) {
    var self = cast(spPathAttachment*, attachment);
    _spVertexAttachment_deinit(&self.super);
    _spFree(cast(void*, self.lengths));
    _spFree(cast(void*, self));
}

spAttachment* _spPathAttachment_copy(spAttachment* attachment) {
    spPathAttachment* copy = spPathAttachment_create(attachment.name);
    var self = cast(spPathAttachment*, attachment);
    spVertexAttachment_copyTo(&self.super, &copy.super);
    copy.lengthsLength = self.lengthsLength;
    copy.lengths = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * self.lengthsLength), "extension.h", 60));
    memcpy(copy.lengths, self.lengths, cast(u64, self.lengthsLength * sizeof(f32)));
    copy.closed = self.closed;
    copy.constantSpeed = self.constantSpeed;
    return &copy.super.super;
}

spPathAttachment* spPathAttachment_create(u8* name) {
    var self = cast(spPathAttachment*, _spCalloc(1, cast(u64, sizeof(spPathAttachment)), "extension.h", 60));
    _spVertexAttachment_init(&self.super);
    _spAttachment_init(&self.super.super, name, SP_ATTACHMENT_PATH, cast(fn(spAttachment*): void, _spPathAttachment_dispose), cast(fn(spAttachment*): spAttachment*, _spPathAttachment_copy));
    return self;
}

spPathConstraint* spPathConstraint_create(spPathConstraintData* data, spSkeleton* skeleton) {
    i32 i;
    var self = cast(spPathConstraint*, _spCalloc(1, cast(u64, sizeof(spPathConstraint)), "extension.h", 87));
    self.data = data;
    self.bonesCount = data.bonesCount;
    self.bones = cast(spBone**, _spMalloc(cast(u64, sizeof(spBone*) * self.bonesCount), "extension.h", 86));
    for i = 0; i < self.bonesCount; ++i {
        self.bones[i] = spSkeleton_findBone(skeleton, self.data.bones[i].name);
    }
    self.target = spSkeleton_findSlot(skeleton, self.data.target.name);
    self.position = data.position;
    self.spacing = data.spacing;
    self.mixRotate = data.mixRotate;
    self.mixX = data.mixX;
    self.mixY = data.mixY;
    self.spacesCount = 0;
    self.spaces = null;
    self.positionsCount = 0;
    self.positions = null;
    self.worldCount = 0;
    self.world = null;
    self.curvesCount = 0;
    self.curves = null;
    self.lengthsCount = 0;
    self.lengths = null;
    return self;
}

void spPathConstraint_dispose(spPathConstraint* self) {
    _spFree(cast(void*, self.bones));
    _spFree(cast(void*, self.spaces));
    if self.positions != null {
        _spFree(cast(void*, self.positions));
    }
    if self.world != null {
        _spFree(cast(void*, self.world));
    }
    if self.curves != null {
        _spFree(cast(void*, self.curves));
    }
    if self.lengths != null {
        _spFree(cast(void*, self.lengths));
    }
    _spFree(cast(void*, self));
}

void spPathConstraint_update(spPathConstraint* self) {
    i32 i;
    i32 p;
    i32 n;
    f32 length;
    f32 setupLength;
    f32 x;
    f32 y;
    f32 dx;
    f32 dy;
    f32 s;
    f32 sum;
    f32* spaces;
    f32* lengths;
    f32* positions;
    f32 spacing;
    f32 boneX;
    f32 boneY;
    f32 offsetRotation;
    i32 tip;
    f32 mixRotate = self.mixRotate;
    f32 mixX = self.mixX;
    f32 mixY = self.mixY;
    i32 lengthSpacing;
    var attachment = cast(spPathAttachment*, self.target.attachment);
    spPathConstraintData* data = self.data;
    i32 tangents = data.rotateMode == SP_ROTATE_MODE_TANGENT;
    i32 scale = data.rotateMode == SP_ROTATE_MODE_CHAIN_SCALE;
    i32 boneCount = self.bonesCount;
    i32 spacesCount = tangents != 0 ? boneCount : boneCount + 1;
    spBone** bones = self.bones;
    spBone* pa;
    if mixRotate == 0.0f && mixX == 0.0f && mixY == 0.0f {
        return;
    }
    if attachment == null || attachment.super.super.type != SP_ATTACHMENT_PATH {
        return;
    }
    if self.spacesCount != spacesCount {
        if self.spaces != null {
            _spFree(cast(void*, self.spaces));
        }
        self.spaces = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * spacesCount), "extension.h", 86));
        self.spacesCount = spacesCount;
    }
    spaces = self.spaces;
    spaces[0] = 0.0f;
    lengths = null;
    spacing = self.spacing;
    if scale != 0 {
        if self.lengthsCount != boneCount {
            if self.lengths != null {
                _spFree(cast(void*, self.lengths));
            }
            self.lengths = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * boneCount), "extension.h", 86));
            self.lengthsCount = boneCount;
        }
        lengths = self.lengths;
    }
    switch data.spacingMode {
        case SP_SPACING_MODE_PERCENT: {
            if scale != 0 {
                {
                    i = 0;
                    for n = spacesCount - 1; i < n; i++ {
                        spBone* bone = bones[i];
                        setupLength = bone.data.length;
                        x = setupLength * bone.a;
                        y = setupLength * bone.c;
                        lengths[i] = sqrtf(x * x + y * y);
                    }
                }
            }
            {
                i = 1;
                for n = spacesCount; i < n; i++ {
                    spaces[i] = spacing;
                }
            }
        }
        case SP_SPACING_MODE_PROPORTIONAL: {
            sum = 0.0f;
            {
                i = 0;
                n = spacesCount - 1;
                while i < n {
                    spBone* bone = bones[i];
                    setupLength = bone.data.length;
                    if setupLength < 1.0e-5f {
                        if scale != 0 {
                            lengths[i] = 0.0f;
                        }
                        spaces[++i] = spacing;
                    } else {
                        x = setupLength * bone.a;
                        y = setupLength * bone.c;
                        length = sqrtf(x * x + y * y);
                        if scale != 0 {
                            lengths[i] = length;
                        }
                        spaces[++i] = length;
                        sum += length;
                    }
                }
            }
            if sum > 0.0f {
                sum = cast(f32, spacesCount) / sum * spacing;
                for i = 1; i < spacesCount; i++ {
                    spaces[i] *= sum;
                }
            }
        }
        default: {
            lengthSpacing = data.spacingMode == SP_SPACING_MODE_LENGTH;
            {
                i = 0;
                n = spacesCount - 1;
                while i < n {
                    spBone* bone = bones[i];
                    setupLength = bone.data.length;
                    if setupLength < 1.0e-5f {
                        if scale != 0 {
                            lengths[i] = 0.0f;
                        }
                        spaces[++i] = spacing;
                    } else {
                        x = setupLength * bone.a;
                        y = setupLength * bone.c;
                        length = sqrtf(x * x + y * y);
                        if scale != 0 {
                            lengths[i] = length;
                        }
                        spaces[++i] = (lengthSpacing != 0 ? setupLength + spacing : spacing) * length / setupLength;
                    }
                }
            }
        }
    }
    positions = spPathConstraint_computeWorldPositions(self, attachment, spacesCount, tangents);
    boneX = positions[0];
    boneY = positions[1];
    offsetRotation = self.data.offsetRotation;
    tip = 0;
    if offsetRotation == 0.0f {
        tip = data.rotateMode == SP_ROTATE_MODE_CHAIN;
    } else {
        tip = 0;
        pa = self.target.bone;
        offsetRotation *= pa.a * pa.d - pa.b * pa.c > 0.0f ? 3.141592653589793f / 180.0f : -(3.141592653589793f / 180.0f);
    }
    {
        i = 0;
        for p = 3; i < boneCount; i++ {
            spBone* bone = bones[i];
            bone.worldX += (boneX - bone.worldX) * mixX;
            bone.worldY += (boneY - bone.worldY) * mixY;
            x = positions[p];
            y = positions[p + 1];
            dx = x - boneX;
            dy = y - boneY;
            if scale != 0 {
                length = lengths[i];
                if length != 0.0f {
                    s = (sqrtf(dx * dx + dy * dy) / length - 1.0f) * mixRotate + 1.0f;
                    bone.a *= s;
                    bone.c *= s;
                }
            }
            boneX = x;
            boneY = y;
            if mixRotate > 0.0f {
                f32 a = bone.a;
                f32 b = bone.b;
                f32 c = bone.c;
                f32 d = bone.d;
                f32 r;
                f32 cosine;
                f32 sine;
                if tangents != 0 {
                    r = positions[p - 1];
                } else if spaces[i + 1] == 0.0f {
                    r = positions[p + 2];
                } else {
                    r = atan2f(dy, dx);
                }
                r -= atan2f(c, a) - offsetRotation * (3.141592653589793f / 180.0f);
                if tip != 0 {
                    cosine = cosf(r);
                    sine = sinf(r);
                    length = bone.data.length;
                    boneX += (length * (cosine * a - sine * c) - dx) * mixRotate;
                    boneY += (length * (sine * a + cosine * c) - dy) * mixRotate;
                } else {
                    r += offsetRotation;
                }
                if r > 3.141592653589793f {
                    r -= 3.141592653589793f * 2.0f;
                } else if r < -3.141592653589793f {
                    r += 3.141592653589793f * 2.0f;
                }
                r *= mixRotate;
                cosine = cosf(r);
                sine = sinf(r);
                bone.a = cosine * a - sine * c;
                bone.b = cosine * b - sine * d;
                bone.c = sine * a + cosine * c;
                bone.d = sine * b + cosine * d;
            }
            spBone_updateAppliedTransform(bone);
            p += 3;
        }
    }
}

void spPathConstraint_setToSetupPose(spPathConstraint* self) {
    spPathConstraintData* data = self.data;
    self.position = data.position;
    self.spacing = data.spacing;
    self.mixRotate = data.mixRotate;
    self.mixX = data.mixX;
    self.mixY = data.mixY;
}

private {
void _addBeforePosition(f32 p, f32* temp, i32 i, f32* out, i32 o) {
    f32 x1 = temp[i];
    f32 y1 = temp[i + 1];
    f32 dx = temp[i + 2] - x1;
    f32 dy = temp[i + 3] - y1;
    f32 r = atan2f(dy, dx);
    out[o] = x1 + p * cosf(r);
    out[o + 1] = y1 + p * sinf(r);
    out[o + 2] = r;
}

void _addAfterPosition(f32 p, f32* temp, i32 i, f32* out, i32 o) {
    f32 x1 = temp[i + 2];
    f32 y1 = temp[i + 3];
    f32 dx = x1 - temp[i];
    f32 dy = y1 - temp[i + 1];
    f32 r = atan2f(dy, dx);
    out[o] = x1 + p * cosf(r);
    out[o + 1] = y1 + p * sinf(r);
    out[o + 2] = r;
}

void _addCurvePosition(f32 p, f32 x1, f32 y1, f32 cx1, f32 cy1, f32 cx2, f32 cy2, f32 x2, f32 y2, f32* out, i32 o, i32 tangents) {
    f32 tt;
    f32 ttt;
    f32 u;
    f32 uu;
    f32 uuu;
    f32 ut;
    f32 ut3;
    f32 uut3;
    f32 utt3;
    f32 x;
    f32 y;
    if p == 0.0f || isnan(p) {
        out[o] = x1;
        out[o + 1] = y1;
        out[o + 2] = atan2f(cy1 - y1, cx1 - x1);
        return;
    }
    tt = p * p;
    ttt = tt * p;
    u = 1.0f - p;
    uu = u * u;
    uuu = uu * u;
    ut = u * p;
    ut3 = ut * 3.0f;
    uut3 = u * ut3;
    utt3 = ut3 * p;
    x = x1 * uuu + cx1 * uut3 + cx2 * utt3 + x2 * ttt;
    y = y1 * uuu + cy1 * uut3 + cy2 * utt3 + y2 * ttt;
    out[o] = x;
    out[o + 1] = y;
    if tangents != 0 {
        if p < 0.001 {
            out[o + 2] = atan2f(cy1 - y1, cx1 - x1);
        } else {
            out[o + 2] = atan2f(y - (y1 * uu + cy1 * ut * 2.0f + cy2 * tt), x - (x1 * uu + cx1 * ut * 2.0f + cx2 * tt));
        }
    }
}
}

f32* spPathConstraint_computeWorldPositions(spPathConstraint* self, spPathAttachment* path, i32 spacesCount, i32 tangents) {
    i32 i;
    i32 o;
    i32 w;
    i32 curve;
    i32 segment;
    i32 closed;
    i32 verticesLength;
    i32 curveCount;
    i32 prevCurve;
    f32* out;
    f32* curves;
    f32* segments;
    f32 tmpx;
    f32 tmpy;
    f32 dddfx;
    f32 dddfy;
    f32 ddfx;
    f32 ddfy;
    f32 dfx;
    f32 dfy;
    f32 pathLength;
    f32 curveLength;
    f32 p;
    f32 x1;
    f32 y1;
    f32 cx1;
    f32 cy1;
    f32 cx2;
    f32 cy2;
    f32 x2;
    f32 y2;
    f32 multiplier;
    spSlot* target = self.target;
    f32 position = self.position;
    f32* spaces = self.spaces;
    f32* world = null;
    if self.positionsCount != spacesCount * 3 + 2 {
        if self.positions != null {
            _spFree(cast(void*, self.positions));
        }
        self.positions = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * (spacesCount * 3 + 2)), "extension.h", 86));
        self.positionsCount = spacesCount * 3 + 2;
    }
    out = self.positions;
    closed = path.closed;
    verticesLength = path.super.worldVerticesLength;
    curveCount = verticesLength / 6;
    prevCurve = -1;
    if path.constantSpeed == 0 {
        f32* lengths = path.lengths;
        curveCount -= closed != 0 ? 1 : 2;
        pathLength = lengths[curveCount];
        if self.data.positionMode == SP_POSITION_MODE_PERCENT {
            position *= pathLength;
        }
        switch self.data.spacingMode {
            case SP_SPACING_MODE_PERCENT: {
                multiplier = pathLength;
            }
            case SP_SPACING_MODE_PROPORTIONAL: {
                multiplier = pathLength / cast(f32, spacesCount);
            }
            default: {
                multiplier = 1.0f;
            }
        }
        if self.worldCount != 8 {
            if self.world != null {
                _spFree(cast(void*, self.world));
            }
            self.world = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * 8), "extension.h", 86));
            self.worldCount = 8;
        }
        world = self.world;
        {
            i = 0;
            o = 0;
            for curve = 0; i < spacesCount; i++ {
                f32 space = spaces[i] * multiplier;
                position += space;
                p = position;
                if closed != 0 {
                    p = fmodf(p, pathLength);
                    if p < 0.0f {
                        p += pathLength;
                    }
                    curve = 0;
                } else if p < 0.0f {
                    if prevCurve != -2 {
                        prevCurve = -2;
                        spVertexAttachment_computeWorldVertices(&path.super, target, 2, 4, world, 0, 2);
                    }
                    _addBeforePosition(p, world, 0, out, o);
                    {
                        o += 3;
                        continue;
                    }
                } else if p > pathLength {
                    if prevCurve != -3 {
                        prevCurve = -3;
                        spVertexAttachment_computeWorldVertices(&path.super, target, verticesLength - 6, 4, world, 0, 2);
                    }
                    _addAfterPosition(p - pathLength, world, 0, out, o);
                    {
                        o += 3;
                        continue;
                    }
                }
                for ; true; curve++ {
                    f32 length = lengths[curve];
                    if p > length {
                        continue;
                    }
                    if curve == 0 {
                        p /= length;
                    } else {
                        f32 prev = lengths[curve - 1];
                        p = (p - prev) / (length - prev);
                    }
                    break;
                }
                if curve != prevCurve {
                    prevCurve = curve;
                    if closed && curve == curveCount {
                        spVertexAttachment_computeWorldVertices(&path.super, target, verticesLength - 4, 4, world, 0, 2);
                        spVertexAttachment_computeWorldVertices(&path.super, target, 0, 4, world, 4, 2);
                    } else {
                        spVertexAttachment_computeWorldVertices(&path.super, target, curve * 6 + 2, 8, world, 0, 2);
                    }
                }
                _addCurvePosition(p, world[0], world[1], world[2], world[3], world[4], world[5], world[6], world[7], out, o, tangents || i > 0 && space == 0.0f);
                o += 3;
            }
        }
        return out;
    }
    if closed != 0 {
        verticesLength += 2;
        if self.worldCount != verticesLength {
            if self.world != null {
                _spFree(cast(void*, self.world));
            }
            self.world = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * verticesLength), "extension.h", 86));
            self.worldCount = verticesLength;
        }
        world = self.world;
        spVertexAttachment_computeWorldVertices(&path.super, target, 2, verticesLength - 4, world, 0, 2);
        spVertexAttachment_computeWorldVertices(&path.super, target, 0, 2, world, verticesLength - 4, 2);
        world[verticesLength - 2] = world[0];
        world[verticesLength - 1] = world[1];
    } else {
        curveCount--;
        verticesLength -= 4;
        if self.worldCount != verticesLength {
            if self.world != null {
                _spFree(cast(void*, self.world));
            }
            self.world = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * verticesLength), "extension.h", 86));
            self.worldCount = verticesLength;
        }
        world = self.world;
        spVertexAttachment_computeWorldVertices(&path.super, target, 2, verticesLength, world, 0, 2);
    }
    if self.curvesCount != curveCount {
        if self.curves != null {
            _spFree(cast(void*, self.curves));
        }
        self.curves = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * curveCount), "extension.h", 86));
        self.curvesCount = curveCount;
    }
    curves = self.curves;
    pathLength = 0.0f;
    x1 = world[0];
    y1 = world[1];
    cx1 = 0.0f;
    cy1 = 0.0f;
    cx2 = 0.0f;
    cy2 = 0.0f;
    x2 = 0.0f;
    y2 = 0.0f;
    {
        i = 0;
        for w = 2; i < curveCount; i++ {
            cx1 = world[w];
            cy1 = world[w + 1];
            cx2 = world[w + 2];
            cy2 = world[w + 3];
            x2 = world[w + 4];
            y2 = world[w + 5];
            tmpx = (x1 - cx1 * 2.0f + cx2) * 0.1875f;
            tmpy = (y1 - cy1 * 2.0f + cy2) * 0.1875f;
            dddfx = ((cx1 - cx2) * 3.0f - x1 + x2) * 0.09375f;
            dddfy = ((cy1 - cy2) * 3.0f - y1 + y2) * 0.09375f;
            ddfx = tmpx * 2.0f + dddfx;
            ddfy = tmpy * 2.0f + dddfy;
            dfx = (cx1 - x1) * 0.75f + tmpx + dddfx * 0.16666667f;
            dfy = (cy1 - y1) * 0.75f + tmpy + dddfy * 0.16666667f;
            pathLength += sqrtf(dfx * dfx + dfy * dfy);
            dfx += ddfx;
            dfy += ddfy;
            ddfx += dddfx;
            ddfy += dddfy;
            pathLength += sqrtf(dfx * dfx + dfy * dfy);
            dfx += ddfx;
            dfy += ddfy;
            pathLength += sqrtf(dfx * dfx + dfy * dfy);
            dfx += ddfx + dddfx;
            dfy += ddfy + dddfy;
            pathLength += sqrtf(dfx * dfx + dfy * dfy);
            curves[i] = pathLength;
            x1 = x2;
            y1 = y2;
            w += 6;
        }
    }
    if self.data.positionMode == SP_POSITION_MODE_PERCENT {
        position *= pathLength;
    }
    switch self.data.spacingMode {
        case SP_SPACING_MODE_PERCENT: {
            multiplier = pathLength;
        }
        case SP_SPACING_MODE_PROPORTIONAL: {
            multiplier = pathLength / cast(f32, spacesCount);
        }
        default: {
            multiplier = 1.0f;
        }
    }
    segments = self.segments;
    curveLength = 0.0f;
    {
        i = 0;
        o = 0;
        curve = 0;
        for segment = 0; i < spacesCount; i++ {
            f32 space = spaces[i] * multiplier;
            position += space;
            p = position;
            if closed != 0 {
                p = fmodf(p, pathLength);
                if p < 0.0f {
                    p += pathLength;
                }
                curve = 0;
            } else if p < 0.0f {
                _addBeforePosition(p, world, 0, out, o);
                {
                    o += 3;
                    continue;
                }
            } else if p > pathLength {
                _addAfterPosition(p - pathLength, world, verticesLength - 4, out, o);
                {
                    o += 3;
                    continue;
                }
            }
            for ; true; curve++ {
                f32 length = curves[curve];
                if p > length {
                    continue;
                }
                if curve == 0 {
                    p /= length;
                } else {
                    f32 prev = curves[curve - 1];
                    p = (p - prev) / (length - prev);
                }
                break;
            }
            if curve != prevCurve {
                i32 ii;
                prevCurve = curve;
                ii = curve * 6;
                x1 = world[ii];
                y1 = world[ii + 1];
                cx1 = world[ii + 2];
                cy1 = world[ii + 3];
                cx2 = world[ii + 4];
                cy2 = world[ii + 5];
                x2 = world[ii + 6];
                y2 = world[ii + 7];
                tmpx = (x1 - cx1 * 2.0f + cx2) * 0.03f;
                tmpy = (y1 - cy1 * 2.0f + cy2) * 0.03f;
                dddfx = ((cx1 - cx2) * 3.0f - x1 + x2) * 0.006f;
                dddfy = ((cy1 - cy2) * 3.0f - y1 + y2) * 0.006f;
                ddfx = tmpx * 2.0f + dddfx;
                ddfy = tmpy * 2.0f + dddfy;
                dfx = (cx1 - x1) * 0.3f + tmpx + dddfx * 0.16666667f;
                dfy = (cy1 - y1) * 0.3f + tmpy + dddfy * 0.16666667f;
                curveLength = sqrtf(dfx * dfx + dfy * dfy);
                segments[0] = curveLength;
                for ii = 1; ii < 8; ii++ {
                    dfx += ddfx;
                    dfy += ddfy;
                    ddfx += dddfx;
                    ddfy += dddfy;
                    curveLength += sqrtf(dfx * dfx + dfy * dfy);
                    segments[ii] = curveLength;
                }
                dfx += ddfx;
                dfy += ddfy;
                curveLength += sqrtf(dfx * dfx + dfy * dfy);
                segments[8] = curveLength;
                dfx += ddfx + dddfx;
                dfy += ddfy + dddfy;
                curveLength += sqrtf(dfx * dfx + dfy * dfy);
                segments[9] = curveLength;
                segment = 0;
            }
            p *= curveLength;
            for ; true; segment++ {
                f32 length = segments[segment];
                if p > length {
                    continue;
                }
                if segment == 0 {
                    p /= length;
                } else {
                    f32 prev = segments[segment - 1];
                    p = cast(f32, segment) + (p - prev) / (length - prev);
                }
                break;
            }
            _addCurvePosition(p * 0.1f, x1, y1, cx1, cy1, cx2, cy2, x2, y2, out, o, tangents || i > 0 && space == 0.0f);
            o += 3;
        }
    }
    return out;
}

spPathConstraintData* spPathConstraintData_create(u8* name) {
    var self = cast(spPathConstraintData*, _spCalloc(1, cast(u64, sizeof(spPathConstraintData)), "extension.h", 44));
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 44));
    strcpy(self.name, name);
    return self;
}

void spPathConstraintData_dispose(spPathConstraintData* self) {
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self.bones));
    _spFree(cast(void*, self));
}

spPhysicsConstraint* spPhysicsConstraint_create(spPhysicsConstraintData* data, spSkeleton* skeleton) {
    var self = cast(spPhysicsConstraint*, _spCalloc(1, cast(u64, sizeof(spPhysicsConstraint)), "extension.h", 101));
    self.data = data;
    self.skeleton = skeleton;
    self.bone = skeleton.bones[data.bone.index];
    self.inertia = data.inertia;
    self.strength = data.strength;
    self.damping = data.damping;
    self.massInverse = data.massInverse;
    self.wind = data.wind;
    self.gravity = data.gravity;
    self.mix = data.mix;
    self.reset = -1;
    self.ux = 0.0f;
    self.uy = 0.0f;
    self.cx = 0.0f;
    self.tx = 0.0f;
    self.ty = 0.0f;
    self.xOffset = 0.0f;
    self.xVelocity = 0.0f;
    self.yOffset = 0.0f;
    self.yVelocity = 0.0f;
    self.rotateOffset = 0.0f;
    self.rotateVelocity = 0.0f;
    self.scaleOffset = 0.0f;
    self.scaleVelocity = 0.0f;
    self.active = 0;
    self.remaining = 0.0f;
    self.lastTime = 0.0f;
    return self;
}

void spPhysicsConstraint_dispose(spPhysicsConstraint* self) {
    _spFree(cast(void*, self));
}

void spPhysicsConstraint_reset(spPhysicsConstraint* self) {
    self.remaining = 0.0f;
    self.lastTime = self.skeleton.time;
    self.reset = -1;
    self.xOffset = 0.0f;
    self.xVelocity = 0.0f;
    self.yOffset = 0.0f;
    self.yVelocity = 0.0f;
    self.rotateOffset = 0.0f;
    self.rotateVelocity = 0.0f;
    self.scaleOffset = 0.0f;
    self.scaleVelocity = 0.0f;
}

void spPhysicsConstraint_setToSetupPose(spPhysicsConstraint* self) {
    self.inertia = self.data.inertia;
    self.strength = self.data.strength;
    self.damping = self.data.damping;
    self.massInverse = self.data.massInverse;
    self.wind = self.data.wind;
    self.gravity = self.data.gravity;
    self.mix = self.data.mix;
}

void spPhysicsConstraint_update(spPhysicsConstraint* self, spPhysics physics) {
    f32 mix = self.mix;
    if mix == 0.0f {
        return;
    }
    i32 x = self.data.x > 0.0f;
    i32 y = self.data.y > 0.0f;
    i32 rotateOrShearX = self.data.rotate > 0.0f || self.data.shearX > 0.0f;
    i32 scaleX = self.data.scaleX > 0.0f;
    spBone* bone = self.bone;
    f32 l = bone.data.length;
    switch physics {
        case SP_PHYSICS_NONE: {
            return;
        }
        case SP_PHYSICS_RESET: {
            spPhysicsConstraint_reset(self);
            fallthrough;
        }
        case SP_PHYSICS_UPDATE: {
            {
                f32 delta = self.skeleton.time - self.lastTime > 0.0f ? self.skeleton.time - self.lastTime : 0.0f;
                self.remaining += delta;
                self.lastTime = self.skeleton.time;
                f32 bx = bone.worldX;
                f32 by = bone.worldY;
                if self.reset != 0 {
                    self.reset = 0;
                    self.ux = bx;
                    self.uy = by;
                } else {
                    f32 a = self.remaining;
                    f32 i = self.inertia;
                    f32 t = self.data.step;
                    f32 f = self.skeleton.data.referenceScale;
                    f32 qx = self.data.limit * delta;
                    f32 qy = qx * (self.skeleton.scaleX < 0.0f ? -self.skeleton.scaleX : self.skeleton.scaleX);
                    qx *= self.skeleton.scaleY < 0.0f ? -self.skeleton.scaleY : self.skeleton.scaleY;
                    if x || y {
                        if x != 0 {
                            f32 u = (self.ux - bx) * i;
                            self.xOffset += u > qx ? qx : u < -qx ? -qx : u;
                            self.ux = bx;
                        }
                        if y != 0 {
                            f32 u = (self.uy - by) * i;
                            self.yOffset += u > qy ? qy : u < -qy ? -qy : u;
                            self.uy = by;
                        }
                        if a >= t {
                            var d = cast(f32, pow(self.damping, 60.0f * t));
                            f32 m = self.massInverse * t;
                            f32 e = self.strength;
                            f32 w = self.wind * f * self.skeleton.scaleX;
                            f32 g = -self.gravity * f * self.skeleton.scaleY;
                            while true {
                                if x != 0 {
                                    self.xVelocity += (w - self.xOffset * e) * m;
                                    self.xOffset += self.xVelocity * t;
                                    self.xVelocity *= d;
                                }
                                if y != 0 {
                                    self.yVelocity -= (g + self.yOffset * e) * m;
                                    self.yOffset += self.yVelocity * t;
                                    self.yVelocity *= d;
                                }
                                a -= t;
                                if !(a >= t) { break; }
                            }
                        }
                        if x != 0 {
                            bone.worldX += self.xOffset * mix * self.data.x;
                        }
                        if y != 0 {
                            bone.worldY += self.yOffset * mix * self.data.y;
                        }
                    }
                    if rotateOrShearX || scaleX {
                        f32 ca = atan2f(bone.c, bone.a);
                        f32 c;
                        f32 s;
                        f32 mr = 0.0f;
                        f32 dx = self.cx - bone.worldX;
                        f32 dy = self.cy - bone.worldY;
                        if dx > qx {
                            dx = qx;
                        } else if dx < -qx {
                            dx = -qx;
                        }
                        if dy > qy {
                            dy = qy;
                        } else if dy < -qy {
                            dy = -qy;
                        }
                        if rotateOrShearX != 0 {
                            mr = (self.data.rotate + self.data.shearX) * mix;
                            f32 r = atan2f(dy + self.ty, dx + self.tx) - ca - self.rotateOffset * mr;
                            self.rotateOffset += (r - cast(f32, ceil(r * (1.0f / (3.141592653589793f * 2.0f)) - 0.5f)) * (3.141592653589793f * 2.0f)) * i;
                            r = self.rotateOffset * mr + ca;
                            c = cosf(r);
                            s = sinf(r);
                            if scaleX != 0 {
                                r = l * spBone_getWorldScaleX(bone);
                                if r > 0.0f {
                                    self.scaleOffset += (dx * c + dy * s) * i / r;
                                }
                            }
                        } else {
                            c = cosf(ca);
                            s = sinf(ca);
                            f32 r = l * spBone_getWorldScaleX(bone);
                            if r > 0.0f {
                                self.scaleOffset += (dx * c + dy * s) * i / r;
                            }
                        }
                        a = self.remaining;
                        if a >= t {
                            f32 m = self.massInverse * t;
                            f32 e = self.strength;
                            f32 w = self.wind;
                            f32 g = self.gravity;
                            f32 h = l / f;
                            var d = cast(f32, pow(self.damping, 60.0f * t));
                            while -1 != 0 {
                                a -= t;
                                if scaleX != 0 {
                                    self.scaleVelocity += (w * c - g * s - self.scaleOffset * e) * m;
                                    self.scaleOffset += self.scaleVelocity * t;
                                    self.scaleVelocity *= d;
                                }
                                if rotateOrShearX != 0 {
                                    self.rotateVelocity -= ((w * s + g * c) * h + self.rotateOffset * e) * m;
                                    self.rotateOffset += self.rotateVelocity * t;
                                    self.rotateVelocity *= d;
                                    if a < t {
                                        break;
                                    }
                                    f32 r = self.rotateOffset * mr + ca;
                                    c = cosf(r);
                                    s = sinf(r);
                                } else if a < t {
                                    break;
                                }
                            }
                        }
                    }
                    self.remaining = a;
                }
                self.cx = bone.worldX;
                self.cy = bone.worldY;
                break case;
            }
        }
        case SP_PHYSICS_POSE: {
            {
                if x != 0 {
                    bone.worldX += self.xOffset * mix * self.data.x;
                }
                if y != 0 {
                    bone.worldY += self.yOffset * mix * self.data.y;
                }
                break case;
            }
        }
    }
    if rotateOrShearX != 0 {
        f32 o = self.rotateOffset * mix;
        f32 s = 0.0f;
        f32 c = 0.0f;
        f32 a = 0.0f;
        if self.data.shearX > 0.0f {
            f32 r = 0.0f;
            if self.data.rotate > 0.0f {
                r = o * self.data.rotate;
                s = sinf(r);
                c = cosf(r);
                a = bone.b;
                bone.b = c * a - s * bone.d;
                bone.d = s * a + c * bone.d;
            }
            r += o * self.data.shearX;
            s = sinf(r);
            c = cosf(r);
            a = bone.a;
            bone.a = c * a - s * bone.c;
            bone.c = s * a + c * bone.c;
        } else {
            o *= self.data.rotate;
            s = sinf(o);
            c = cosf(o);
            a = bone.a;
            bone.a = c * a - s * bone.c;
            bone.c = s * a + c * bone.c;
            a = bone.b;
            bone.b = c * a - s * bone.d;
            bone.d = s * a + c * bone.d;
        }
    }
    if scaleX != 0 {
        f32 s = 1.0f + self.scaleOffset * mix * self.data.scaleX;
        bone.a *= s;
        bone.c *= s;
    }
    if physics != SP_PHYSICS_POSE {
        self.tx = l * bone.a;
        self.ty = l * bone.c;
    }
    spBone_updateAppliedTransform(bone);
}

void spPhysicsConstraint_rotate(spPhysicsConstraint* self, f32 x, f32 y, f32 degrees) {
    f32 r = degrees * (3.141592653589793f / 180.0f);
    f32 cosine = cosf(r);
    f32 sine = sinf(r);
    f32 dx = self.cx - x;
    f32 dy = self.cy - y;
    spPhysicsConstraint_translate(self, dx * cosine - dy * sine - dx, dx * sine + dy * cosine - dy);
}

void spPhysicsConstraint_translate(spPhysicsConstraint* self, f32 x, f32 y) {
    self.ux -= x;
    self.uy -= y;
    self.cx -= x;
    self.cy -= y;
}

spPhysicsConstraintData* spPhysicsConstraintData_create(u8* name) {
    var self = cast(spPhysicsConstraintData*, _spCalloc(1, cast(u64, sizeof(spPhysicsConstraintData)), "extension.h", 65));
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 65));
    strcpy(self.name, name);
    self.bone = null;
    self.x = 0.0f;
    self.y = 0.0f;
    self.rotate = 0.0f;
    self.scaleX = 0.0f;
    self.shearX = 0.0f;
    self.limit = 0.0f;
    self.step = 0.0f;
    self.inertia = 0.0f;
    self.strength = 0.0f;
    self.damping = 0.0f;
    self.massInverse = 0.0f;
    self.wind = 0.0f;
    self.gravity = 0.0f;
    self.mix = 0.0f;
    self.inertiaGlobal = 0;
    self.strengthGlobal = 0;
    self.dampingGlobal = 0;
    self.massGlobal = 0;
    self.windGlobal = 0;
    self.gravityGlobal = 0;
    self.mixGlobal = 0;
    return self;
}

void spPhysicsConstraintData_dispose(spPhysicsConstraintData* self) {
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self));
}

void _spPointAttachment_dispose(spAttachment* attachment) {
    var self = cast(spPointAttachment*, attachment);
    _spAttachment_deinit(attachment);
    _spFree(cast(void*, self));
}

spAttachment* _spPointAttachment_copy(spAttachment* attachment) {
    var self = cast(spPointAttachment*, attachment);
    spPointAttachment* copy = spPointAttachment_create(attachment.name);
    copy.x = self.x;
    copy.y = self.y;
    copy.rotation = self.rotation;
    spColor_setFromColor(&copy.color, &self.color);
    return &copy.super;
}

spPointAttachment* spPointAttachment_create(u8* name) {
    var self = cast(spPointAttachment*, _spCalloc(1, cast(u64, sizeof(spPointAttachment)), "extension.h", 66));
    _spAttachment_init(&self.super, name, SP_ATTACHMENT_POINT, cast(fn(spAttachment*): void, _spPointAttachment_dispose), cast(fn(spAttachment*): spAttachment*, _spPointAttachment_copy));
    return self;
}

void spPointAttachment_computeWorldPosition(spPointAttachment* self, spBone* bone, f32* x, f32* y) {
    *x = self.x * bone.a + self.y * bone.b + bone.worldX;
    *y = self.x * bone.c + self.y * bone.d + bone.worldY;
}

f32 spPointAttachment_computeWorldRotation(spPointAttachment* self, spBone* bone) {
    f32 r = self.rotation * (3.141592653589793f / 180.0f);
    f32 cosine = cosf(r);
    f32 sine = sinf(r);
    f32 x = cosine * bone.a + sine * bone.b;
    f32 y = cosine * bone.c + sine * bone.d;
    return atan2f(y, x) * (180.0f / 3.141592653589793f);
}

void _spRegionAttachment_dispose(spAttachment* attachment) {
    var self = cast(spRegionAttachment*, attachment);
    if self.sequence != null {
        spSequence_dispose(self.sequence);
    }
    _spAttachment_deinit(attachment);
    _spFree(cast(void*, self.path));
    _spFree(cast(void*, self));
}

spAttachment* _spRegionAttachment_copy(spAttachment* attachment) {
    var self = cast(spRegionAttachment*, attachment);
    spRegionAttachment* copy = spRegionAttachment_create(attachment.name);
    copy.region = self.region;
    copy.rendererObject = self.rendererObject;
    copy.path = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(self.path) + 1), "extension.h", 84));
    strcpy(copy.path, self.path);
    copy.x = self.x;
    copy.y = self.y;
    copy.scaleX = self.scaleX;
    copy.scaleY = self.scaleY;
    copy.rotation = self.rotation;
    copy.width = self.width;
    copy.height = self.height;
    memcpy(copy.uvs, self.uvs, cast(u64, sizeof(f32) * 8));
    memcpy(copy.offset, self.offset, cast(u64, sizeof(f32) * 8));
    spColor_setFromColor(&copy.color, &self.color);
    copy.sequence = self.sequence != null ? spSequence_copy(self.sequence) : null;
    return &copy.super;
}

spRegionAttachment* spRegionAttachment_create(u8* name) {
    var self = cast(spRegionAttachment*, _spCalloc(1, cast(u64, sizeof(spRegionAttachment)), "extension.h", 89));
    self.scaleX = 1.0f;
    self.scaleY = 1.0f;
    spColor_setFromFloats(&self.color, 1.0f, 1.0f, 1.0f, 1.0f);
    _spAttachment_init(&self.super, name, SP_ATTACHMENT_REGION, cast(fn(spAttachment*): void, _spRegionAttachment_dispose), cast(fn(spAttachment*): spAttachment*, _spRegionAttachment_copy));
    return self;
}

void spRegionAttachment_updateRegion(spRegionAttachment* self) {
    f32 regionScaleX;
    f32 regionScaleY;
    f32 localX;
    f32 localY;
    f32 localX2;
    f32 localY2;
    f32 radians;
    f32 cosine;
    f32 sine;
    f32 localXCos;
    f32 localXSin;
    f32 localYCos;
    f32 localYSin;
    f32 localX2Cos;
    f32 localX2Sin;
    f32 localY2Cos;
    f32 localY2Sin;
    if self.region == null {
        self.uvs[0] = 0.0f;
        self.uvs[1] = 0.0f;
        self.uvs[2] = 1.0f;
        self.uvs[3] = 1.0f;
        self.uvs[4] = 1.0f;
        self.uvs[5] = 0.0f;
        self.uvs[6] = 0.0f;
        self.uvs[7] = 0.0f;
        return;
    }
    regionScaleX = self.width / cast(f32, self.region.originalWidth) * self.scaleX;
    regionScaleY = self.height / cast(f32, self.region.originalHeight) * self.scaleY;
    localX = -self.width / 2.0f * self.scaleX + self.region.offsetX * regionScaleX;
    localY = -self.height / 2.0f * self.scaleY + self.region.offsetY * regionScaleY;
    localX2 = localX + cast(f32, self.region.width) * regionScaleX;
    localY2 = localY + cast(f32, self.region.height) * regionScaleY;
    radians = self.rotation * (3.141592653589793f / 180.0f);
    cosine = cosf(radians);
    sine = sinf(radians);
    localXCos = localX * cosine + self.x;
    localXSin = localX * sine;
    localYCos = localY * cosine + self.y;
    localYSin = localY * sine;
    localX2Cos = localX2 * cosine + self.x;
    localX2Sin = localX2 * sine;
    localY2Cos = localY2 * cosine + self.y;
    localY2Sin = localY2 * sine;
    self.offset[BLX] = localXCos - localYSin;
    self.offset[BLY] = localYCos + localXSin;
    self.offset[ULX] = localXCos - localY2Sin;
    self.offset[ULY] = localY2Cos + localXSin;
    self.offset[URX] = localX2Cos - localY2Sin;
    self.offset[URY] = localY2Cos + localX2Sin;
    self.offset[BRX] = localX2Cos - localYSin;
    self.offset[BRY] = localYCos + localX2Sin;
    if self.region.degrees == 90 {
        self.uvs[URX] = self.region.u;
        self.uvs[URY] = self.region.v2;
        self.uvs[BRX] = self.region.u;
        self.uvs[BRY] = self.region.v;
        self.uvs[BLX] = self.region.u2;
        self.uvs[BLY] = self.region.v;
        self.uvs[ULX] = self.region.u2;
        self.uvs[ULY] = self.region.v2;
    } else {
        self.uvs[ULX] = self.region.u;
        self.uvs[ULY] = self.region.v2;
        self.uvs[URX] = self.region.u;
        self.uvs[URY] = self.region.v;
        self.uvs[BRX] = self.region.u2;
        self.uvs[BRY] = self.region.v;
        self.uvs[BLX] = self.region.u2;
        self.uvs[BLY] = self.region.v2;
    }
}

void spRegionAttachment_computeWorldVertices(spRegionAttachment* self, spSlot* slot, f32* vertices, i32 offset, i32 stride) {
    f32* offsets = self.offset;
    spBone* bone = slot.bone;
    f32 x = bone.worldX;
    f32 y = bone.worldY;
    f32 offsetX;
    f32 offsetY;
    if self.sequence != null {
        spSequence_apply(self.sequence, slot, &self.super);
    }
    offsetX = offsets[BRX];
    offsetY = offsets[BRY];
    vertices[offset] = offsetX * bone.a + offsetY * bone.b + x;
    vertices[offset + 1] = offsetX * bone.c + offsetY * bone.d + y;
    offset += stride;
    offsetX = offsets[BLX];
    offsetY = offsets[BLY];
    vertices[offset] = offsetX * bone.a + offsetY * bone.b + x;
    vertices[offset + 1] = offsetX * bone.c + offsetY * bone.d + y;
    offset += stride;
    offsetX = offsets[ULX];
    offsetY = offsets[ULY];
    vertices[offset] = offsetX * bone.a + offsetY * bone.b + x;
    vertices[offset + 1] = offsetX * bone.c + offsetY * bone.d + y;
    offset += stride;
    offsetX = offsets[URX];
    offsetY = offsets[URY];
    vertices[offset] = offsetX * bone.a + offsetY * bone.b + x;
    vertices[offset + 1] = offsetX * bone.c + offsetY * bone.d + y;
}

spTextureRegionArray* spTextureRegionArray_create(i32 initialCapacity) {
    var array = cast(spTextureRegionArray*, _spCalloc(1, cast(u64, sizeof(spTextureRegionArray)), "extension.h", 93));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spTextureRegion**, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spTextureRegion*)), "extension.h", 93));
    return array;
}

void spTextureRegionArray_dispose(spTextureRegionArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spTextureRegionArray_clear(spTextureRegionArray* self) {
    self.size = 0;
}

spTextureRegionArray* spTextureRegionArray_setSize(spTextureRegionArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spTextureRegion**, _spRealloc(self.items, cast(u64, sizeof(spTextureRegion*) * self.capacity)));
    }
    return self;
}

void spTextureRegionArray_ensureCapacity(spTextureRegionArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spTextureRegion**, _spRealloc(self.items, cast(u64, sizeof(spTextureRegion*) * self.capacity)));
}

void spTextureRegionArray_add(spTextureRegionArray* self, spTextureRegion* value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spTextureRegion**, _spRealloc(self.items, cast(u64, sizeof(spTextureRegion*) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spTextureRegionArray_addAll(spTextureRegionArray* self, spTextureRegionArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spTextureRegionArray_add(self, other.items[i]);
    }
}

void spTextureRegionArray_addAllValues(spTextureRegionArray* self, spTextureRegion** values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spTextureRegionArray_add(self, values[i]);
    }
}

void spTextureRegionArray_removeAt(spTextureRegionArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spTextureRegion*) * (self.size - index)));
}

i32 spTextureRegionArray_contains(spTextureRegionArray* self, spTextureRegion* value) {
    spTextureRegion** items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spTextureRegion* spTextureRegionArray_pop(spTextureRegionArray* self) {
    spTextureRegion* item = self.items[--self.size];
    return item;
}

spTextureRegion* spTextureRegionArray_peek(spTextureRegionArray* self) {
    return self.items[self.size - 1];
}
private { i32 nextSequenceId = 0; }

spSequence* spSequence_create(i32 numRegions) {
    var self = cast(spSequence*, _spCalloc(1, cast(u64, sizeof(spSequence)), "extension.h", 93));
    self.id = nextSequenceId++;
    self.regions = spTextureRegionArray_create(numRegions);
    spTextureRegionArray_setSize(self.regions, numRegions);
    return self;
}

void spSequence_dispose(spSequence* self) {
    _spFree(cast(void*, self.regions));
    _spFree(cast(void*, self));
}

spSequence* spSequence_copy(spSequence* self) {
    i32 i = 0;
    spSequence* copy = spSequence_create(self.regions.size);
    for ; i < self.regions.size; i++ {
        copy.regions.items[i] = self.regions.items[i];
    }
    copy.start = self.start;
    copy.digits = self.digits;
    copy.setupIndex = self.setupIndex;
    return copy;
}

void spSequence_apply(spSequence* self, spSlot* slot, spAttachment* attachment) {
    i32 index = slot.sequenceIndex;
    spTextureRegion* region = null;
    if index == -1 {
        index = self.setupIndex;
    }
    if index >= self.regions.size {
        index = self.regions.size - 1;
    }
    region = self.regions.items[index];
    if attachment.type == SP_ATTACHMENT_REGION {
        var regionAttachment = cast(spRegionAttachment*, attachment);
        if regionAttachment.region != region {
            regionAttachment.rendererObject = region;
            regionAttachment.region = region;
            spRegionAttachment_updateRegion(regionAttachment);
        }
    }
    if attachment.type == SP_ATTACHMENT_MESH {
        var meshAttachment = cast(spMeshAttachment*, attachment);
        if meshAttachment.region != region {
            meshAttachment.rendererObject = region;
            meshAttachment.region = region;
            spMeshAttachment_updateRegion(meshAttachment);
        }
    }
}

private {
i32 num_digits(i32 value) {
    i32 count = value < 0 ? 1 : 0;
    while true {
        value /= 10;
        ++count;
        if !(value != 0) { break; }
    }
    return count;
}

u8* string_append(u8* str_var, u8* b) {
    var lenB = cast(i32, strlen(b));
    memcpy(str_var, b, cast(u64, lenB + 1));
    return str_var + lenB;
}

u8* string_append_int(u8* str_var, i32 value) {
    noinit u8[20] intStr;
    snprintf(intStr, 20, "%i", value);
    return string_append(str_var, intStr);
}
}

void spSequence_getPath(spSequence* self, u8* basePath, i32 index, u8* path) {
    i32 i;
    path = string_append(path, basePath);
    for i = self.digits - num_digits(self.start + index); i > 0; i-- {
        path = string_append(path, "0");
    }
    path = string_append_int(path, self.start + index);
}

spSkeleton* spSkeleton_create(spSkeletonData* data) {
    i32 i;
    i32* childrenCounts;
    var internal = cast(_spSkeleton*, _spCalloc(1, cast(u64, sizeof(_spSkeleton)), "extension.h", 101));
    spSkeleton* self = &internal.super;
    self.data = data;
    self.skin = null;
    spColor_setFromFloats(&self.color, 1.0f, 1.0f, 1.0f, 1.0f);
    self.scaleX = 1.0f;
    self.scaleY = 1.0f;
    self.time = 0.0f;
    self.bonesCount = self.data.bonesCount;
    self.bones = cast(spBone**, _spMalloc(cast(u64, sizeof(spBone*) * self.bonesCount), "extension.h", 99));
    childrenCounts = cast(i32*, _spCalloc(cast(u64, self.bonesCount), cast(u64, sizeof(i32)), "extension.h", 101));
    for i = 0; i < self.bonesCount; ++i {
        spBoneData* boneData = self.data.bones[i];
        spBone* newBone;
        if boneData.parent == null {
            newBone = spBone_create(boneData, self, null);
        } else {
            spBone* parent = self.bones[boneData.parent.index];
            newBone = spBone_create(boneData, self, parent);
            ++childrenCounts[boneData.parent.index];
        }
        self.bones[i] = newBone;
    }
    for i = 0; i < self.bonesCount; ++i {
        spBoneData* boneData = self.data.bones[i];
        spBone* bone = self.bones[i];
        bone.children = cast(spBone**, _spMalloc(cast(u64, sizeof(spBone*) * childrenCounts[boneData.index]), "extension.h", 99));
    }
    for i = 0; i < self.bonesCount; ++i {
        spBone* bone = self.bones[i];
        spBone* parent = bone.parent;
        if parent != null {
            parent.children[parent.childrenCount++] = bone;
        }
    }
    self.root = self.bonesCount > 0 ? self.bones[0] : null;
    self.slotsCount = data.slotsCount;
    self.slots = cast(spSlot**, _spMalloc(cast(u64, sizeof(spSlot*) * self.slotsCount), "extension.h", 99));
    for i = 0; i < self.slotsCount; ++i {
        spSlotData* slotData = data.slots[i];
        spBone* bone = self.bones[slotData.boneData.index];
        self.slots[i] = spSlot_create(slotData, bone);
    }
    self.drawOrder = cast(spSlot**, _spMalloc(cast(u64, sizeof(spSlot*) * self.slotsCount), "extension.h", 99));
    memcpy(self.drawOrder, self.slots, cast(u64, sizeof(spSlot*) * self.slotsCount));
    self.ikConstraintsCount = data.ikConstraintsCount;
    self.ikConstraints = cast(spIkConstraint**, _spMalloc(cast(u64, sizeof(spIkConstraint*) * self.ikConstraintsCount), "extension.h", 99));
    for i = 0; i < self.data.ikConstraintsCount; ++i {
        self.ikConstraints[i] = spIkConstraint_create(self.data.ikConstraints[i], self);
    }
    self.transformConstraintsCount = data.transformConstraintsCount;
    self.transformConstraints = cast(spTransformConstraint**, _spMalloc(cast(u64, sizeof(spTransformConstraint*) * self.transformConstraintsCount), "extension.h", 99));
    for i = 0; i < self.data.transformConstraintsCount; ++i {
        self.transformConstraints[i] = spTransformConstraint_create(self.data.transformConstraints[i], self);
    }
    self.pathConstraintsCount = data.pathConstraintsCount;
    self.pathConstraints = cast(spPathConstraint**, _spMalloc(cast(u64, sizeof(spPathConstraint*) * self.pathConstraintsCount), "extension.h", 99));
    for i = 0; i < self.data.pathConstraintsCount; i++ {
        self.pathConstraints[i] = spPathConstraint_create(self.data.pathConstraints[i], self);
    }
    self.physicsConstraintsCount = data.physicsConstraintsCount;
    self.physicsConstraints = cast(spPhysicsConstraint**, _spMalloc(cast(u64, sizeof(spPhysicsConstraint*) * self.physicsConstraintsCount), "extension.h", 99));
    for i = 0; i < self.data.physicsConstraintsCount; i++ {
        self.physicsConstraints[i] = spPhysicsConstraint_create(self.data.physicsConstraints[i], self);
    }
    spColor_setFromFloats(&self.color, 1.0f, 1.0f, 1.0f, 1.0f);
    self.scaleX = 1.0f;
    self.scaleY = 1.0f;
    self.time = 0.0f;
    spSkeleton_updateCache(self);
    _spFree(cast(void*, childrenCounts));
    return self;
}

void spSkeleton_dispose(spSkeleton* self) {
    i32 i;
    var internal = cast(_spSkeleton*, self);
    _spFree(cast(void*, internal.updateCache));
    for i = 0; i < self.bonesCount; ++i {
        spBone_dispose(self.bones[i]);
    }
    _spFree(cast(void*, self.bones));
    for i = 0; i < self.slotsCount; ++i {
        spSlot_dispose(self.slots[i]);
    }
    _spFree(cast(void*, self.slots));
    for i = 0; i < self.ikConstraintsCount; ++i {
        spIkConstraint_dispose(self.ikConstraints[i]);
    }
    _spFree(cast(void*, self.ikConstraints));
    for i = 0; i < self.transformConstraintsCount; ++i {
        spTransformConstraint_dispose(self.transformConstraints[i]);
    }
    _spFree(cast(void*, self.transformConstraints));
    for i = 0; i < self.pathConstraintsCount; i++ {
        spPathConstraint_dispose(self.pathConstraints[i]);
    }
    _spFree(cast(void*, self.pathConstraints));
    for i = 0; i < self.physicsConstraintsCount; i++ {
        spPhysicsConstraint_dispose(self.physicsConstraints[i]);
    }
    _spFree(cast(void*, self.physicsConstraints));
    _spFree(cast(void*, self.drawOrder));
    _spFree(cast(void*, self));
}

private {
void _addToUpdateCache(_spSkeleton* internal, _spUpdateType type, void* object) {
    _spUpdate* update;
    if internal.updateCacheCount == internal.updateCacheCapacity {
        internal.updateCacheCapacity *= 2;
        internal.updateCache = cast(_spUpdate*, _spRealloc(internal.updateCache, cast(u64, sizeof(_spUpdate) * internal.updateCacheCapacity)));
    }
    update = internal.updateCache + internal.updateCacheCount;
    update.type = type;
    update.object = object;
    ++internal.updateCacheCount;
}

void _sortBone(_spSkeleton* internal, spBone* bone) {
    if bone.sorted != 0 {
        return;
    }
    if bone.parent != null {
        _sortBone(internal, bone.parent);
    }
    bone.sorted = 1;
    _addToUpdateCache(internal, SP_UPDATE_BONE, bone);
}

void _sortPathConstraintAttachmentBones(_spSkeleton* internal, spAttachment* attachment, spBone* slotBone) {
    var pathAttachment = cast(spPathAttachment*, attachment);
    i32* pathBones;
    i32 pathBonesCount;
    if pathAttachment.super.super.type != SP_ATTACHMENT_PATH {
        return;
    }
    pathBones = pathAttachment.super.bones;
    pathBonesCount = pathAttachment.super.bonesCount;
    if pathBones == null {
        _sortBone(internal, slotBone);
    } else {
        spBone** bones = internal.super.bones;
        i32 i = 0;
        i32 n;
        {
            i = 0;
            n = pathBonesCount;
            while i < n {
                i32 nn = pathBones[i++];
                nn += i;
                while i < nn {
                    _sortBone(internal, bones[pathBones[i++]]);
                }
            }
        }
    }
}

void _sortPathConstraintAttachment(_spSkeleton* internal, spSkin* skin, i32 slotIndex, spBone* slotBone) {
    _Entry* entry = cast(_spSkin*, skin).entries;
    while entry != null {
        if entry.slotIndex == slotIndex {
            _sortPathConstraintAttachmentBones(internal, entry.attachment, slotBone);
        }
        entry = entry.next;
    }
}

void _sortReset(spBone** bones, i32 bonesCount) {
    i32 i;
    for i = 0; i < bonesCount; ++i {
        spBone* bone = bones[i];
        if bone.active == 0 {
            continue;
        }
        if bone.sorted != 0 {
            _sortReset(bone.children, bone.childrenCount);
        }
        bone.sorted = 0;
    }
}

void _sortIkConstraint(_spSkeleton* internal, spIkConstraint* constraint) {
    spBone* target = constraint.target;
    spBone** constrained;
    spBone* parent;
    constraint.active = constraint.target.active && (!constraint.data.skinRequired || internal.super.skin != null && spIkConstraintDataArray_contains(internal.super.skin.ikConstraints, constraint.data));
    if constraint.active == 0 {
        return;
    }
    _sortBone(internal, target);
    constrained = constraint.bones;
    parent = constrained[0];
    _sortBone(internal, parent);
    if constraint.bonesCount == 1 {
        _addToUpdateCache(internal, SP_UPDATE_IK_CONSTRAINT, constraint);
        _sortReset(parent.children, parent.childrenCount);
    } else {
        spBone* child = constrained[constraint.bonesCount - 1];
        _sortBone(internal, child);
        _addToUpdateCache(internal, SP_UPDATE_IK_CONSTRAINT, constraint);
        _sortReset(parent.children, parent.childrenCount);
        child.sorted = 1;
    }
}

void _sortPathConstraint(_spSkeleton* internal, spPathConstraint* constraint) {
    spSlot* slot = constraint.target;
    i32 slotIndex = slot.data.index;
    spBone* slotBone = slot.bone;
    i32 i;
    i32 n;
    i32 boneCount;
    spAttachment* attachment;
    spBone** constrained;
    var skeleton = cast(spSkeleton*, internal);
    constraint.active = constraint.target.bone.active && (!constraint.data.skinRequired || internal.super.skin != null && spPathConstraintDataArray_contains(internal.super.skin.pathConstraints, constraint.data));
    if constraint.active == 0 {
        return;
    }
    if skeleton.skin != null {
        _sortPathConstraintAttachment(internal, skeleton.skin, slotIndex, slotBone);
    }
    if skeleton.data.defaultSkin && skeleton.data.defaultSkin != skeleton.skin {
        _sortPathConstraintAttachment(internal, skeleton.data.defaultSkin, slotIndex, slotBone);
    }
    {
        i = 0;
        for n = skeleton.data.skinsCount; i < n; i++ {
            _sortPathConstraintAttachment(internal, skeleton.data.skins[i], slotIndex, slotBone);
        }
    }
    attachment = slot.attachment;
    if attachment && attachment.type == SP_ATTACHMENT_PATH {
        _sortPathConstraintAttachmentBones(internal, attachment, slotBone);
    }
    constrained = constraint.bones;
    boneCount = constraint.bonesCount;
    for i = 0; i < boneCount; i++ {
        _sortBone(internal, constrained[i]);
    }
    _addToUpdateCache(internal, SP_UPDATE_PATH_CONSTRAINT, constraint);
    for i = 0; i < boneCount; i++ {
        _sortReset(constrained[i].children, constrained[i].childrenCount);
    }
    for i = 0; i < boneCount; i++ {
        constrained[i].sorted = 1;
    }
}

void _sortTransformConstraint(_spSkeleton* internal, spTransformConstraint* constraint) {
    i32 i;
    i32 boneCount;
    spBone** constrained;
    spBone* child;
    constraint.active = constraint.target.active && (!constraint.data.skinRequired || internal.super.skin != null && spTransformConstraintDataArray_contains(internal.super.skin.transformConstraints, constraint.data));
    if constraint.active == 0 {
        return;
    }
    _sortBone(internal, constraint.target);
    constrained = constraint.bones;
    boneCount = constraint.bonesCount;
    if constraint.data.local != 0 {
        for i = 0; i < boneCount; i++ {
            child = constrained[i];
            _sortBone(internal, child.parent);
            _sortBone(internal, child);
        }
    } else {
        for i = 0; i < boneCount; i++ {
            _sortBone(internal, constrained[i]);
        }
    }
    _addToUpdateCache(internal, SP_UPDATE_TRANSFORM_CONSTRAINT, constraint);
    for i = 0; i < boneCount; i++ {
        _sortReset(constrained[i].children, constrained[i].childrenCount);
    }
    for i = 0; i < boneCount; i++ {
        constrained[i].sorted = 1;
    }
}

void _sortPhysicsConstraint(_spSkeleton* internal, spPhysicsConstraint* constraint) {
    spBone* bone = constraint.bone;
    constraint.active = constraint.bone.active && (!constraint.data.skinRequired || internal.super.skin != null && spPhysicsConstraintDataArray_contains(internal.super.skin.physicsConstraints, constraint.data));
    if constraint.active == 0 {
        return;
    }
    _sortBone(internal, bone);
    _addToUpdateCache(internal, SP_UPDATE_PHYSICS_CONSTRAINT, constraint);
    _sortReset(bone.children, bone.childrenCount);
    bone.sorted = -1;
}
}

void spSkeleton_updateCache(spSkeleton* self) {
    i32 i;
    i32 ii;
    spBone** bones;
    spIkConstraint** ikConstraints;
    spPathConstraint** pathConstraints;
    spTransformConstraint** transformConstraints;
    spPhysicsConstraint** physicsConstraints;
    i32 ikCount;
    i32 transformCount;
    i32 pathCount;
    i32 physicsCount;
    i32 constraintCount;
    var internal = cast(_spSkeleton*, self);
    internal.updateCacheCapacity = self.bonesCount + self.ikConstraintsCount + self.transformConstraintsCount + self.pathConstraintsCount + self.physicsConstraintsCount;
    _spFree(cast(void*, internal.updateCache));
    internal.updateCache = cast(_spUpdate*, _spMalloc(cast(u64, sizeof(_spUpdate) * internal.updateCacheCapacity), "extension.h", 99));
    internal.updateCacheCount = 0;
    bones = self.bones;
    for i = 0; i < self.bonesCount; ++i {
        spBone* bone = bones[i];
        bone.sorted = bone.data.skinRequired;
        bone.active = !bone.sorted;
    }
    if self.skin != null {
        spBoneDataArray* skinBones = self.skin.bones;
        for i = 0; i < skinBones.size; i++ {
            spBone* bone = self.bones[skinBones.items[i].index];
            while true {
                bone.sorted = 0;
                bone.active = -1;
                bone = bone.parent;
                if !(bone != null) { break; }
            }
        }
    }
    ikConstraints = self.ikConstraints;
    transformConstraints = self.transformConstraints;
    pathConstraints = self.pathConstraints;
    physicsConstraints = self.physicsConstraints;
    ikCount = self.ikConstraintsCount;
    transformCount = self.transformConstraintsCount;
    pathCount = self.pathConstraintsCount;
    physicsCount = self.physicsConstraintsCount;
    constraintCount = ikCount + transformCount + pathCount + physicsCount;
    i = 0;
    bool __retry_continue_outer = false;
    while true {
        __retry_continue_outer = false;
        {
            for ; i < constraintCount; i++ {
                {
                    for ii = 0; ii < ikCount; ii++ {
                        spIkConstraint* ikConstraint = ikConstraints[ii];
                        if ikConstraint.data.order == i {
                            _sortIkConstraint(internal, ikConstraint);
                            i++;
                            {
                                __retry_continue_outer = true;
                                break;
                            }
                        }
                    }
                    if __retry_continue_outer {
                        break;
                    }
                }
                {
                    for ii = 0; ii < transformCount; ii++ {
                        spTransformConstraint* transformConstraint = transformConstraints[ii];
                        if transformConstraint.data.order == i {
                            _sortTransformConstraint(internal, transformConstraint);
                            i++;
                            {
                                __retry_continue_outer = true;
                                break;
                            }
                        }
                    }
                    if __retry_continue_outer {
                        break;
                    }
                }
                {
                    for ii = 0; ii < pathCount; ii++ {
                        spPathConstraint* pathConstraint = pathConstraints[ii];
                        if pathConstraint.data.order == i {
                            _sortPathConstraint(internal, pathConstraint);
                            i++;
                            {
                                __retry_continue_outer = true;
                                break;
                            }
                        }
                    }
                    if __retry_continue_outer {
                        break;
                    }
                }
                {
                    for ii = 0; ii < physicsCount; ii++ {
                        spPhysicsConstraint* physicsConstraint = physicsConstraints[ii];
                        if physicsConstraint.data.order == i {
                            _sortPhysicsConstraint(internal, physicsConstraint);
                            i++;
                            {
                                __retry_continue_outer = true;
                                break;
                            }
                        }
                    }
                    if __retry_continue_outer {
                        break;
                    }
                }
            }
            if __retry_continue_outer {
                continue;
            }
        }
        for i = 0; i < self.bonesCount; ++i {
            _sortBone(internal, self.bones[i]);
        }
        break;
    }
}

void spSkeleton_updateWorldTransform(spSkeleton* self, spPhysics physics) {
    i32 i;
    i32 n;
    var internal = cast(_spSkeleton*, self);
    {
        i = 0;
        for n = self.bonesCount; i < n; i++ {
            spBone* bone = self.bones[i];
            bone.ax = bone.x;
            bone.ay = bone.y;
            bone.arotation = bone.rotation;
            bone.ascaleX = bone.scaleX;
            bone.ascaleY = bone.scaleY;
            bone.ashearX = bone.shearX;
            bone.ashearY = bone.shearY;
        }
    }
    for i = 0; i < internal.updateCacheCount; ++i {
        _spUpdate* update = internal.updateCache + i;
        switch update.type {
            case SP_UPDATE_BONE: {
                spBone_update(cast(spBone*, update.object));
            }
            case SP_UPDATE_IK_CONSTRAINT: {
                spIkConstraint_update(cast(spIkConstraint*, update.object));
            }
            case SP_UPDATE_TRANSFORM_CONSTRAINT: {
                spTransformConstraint_update(cast(spTransformConstraint*, update.object));
            }
            case SP_UPDATE_PATH_CONSTRAINT: {
                spPathConstraint_update(cast(spPathConstraint*, update.object));
            }
            case SP_UPDATE_PHYSICS_CONSTRAINT: {
                spPhysicsConstraint_update(cast(spPhysicsConstraint*, update.object), physics);
            }
        }
    }
}

void spSkeleton_update(spSkeleton* self, f32 delta) {
    self.time += delta;
}

void spSkeleton_updateWorldTransformWith(spSkeleton* self, spBone* parent, spPhysics physics) {
    i32 i;
    f32 rotationY;
    f32 la;
    f32 lb;
    f32 lc;
    f32 ld;
    var internal = cast(_spSkeleton*, self);
    spBone* rootBone = self.root;
    f32 pa = parent.a;
    f32 pb = parent.b;
    f32 pc = parent.c;
    f32 pd = parent.d;
    rootBone.worldX = pa * self.x + pb * self.y + parent.worldX;
    rootBone.worldY = pc * self.x + pd * self.y + parent.worldY;
    rotationY = rootBone.rotation + 90.0f + rootBone.shearY;
    la = cosf((rootBone.rotation + rootBone.shearX) * (3.141592653589793f / 180.0f)) * rootBone.scaleX;
    lb = cosf(rotationY * (3.141592653589793f / 180.0f)) * rootBone.scaleY;
    lc = sinf((rootBone.rotation + rootBone.shearX) * (3.141592653589793f / 180.0f)) * rootBone.scaleX;
    ld = sinf(rotationY * (3.141592653589793f / 180.0f)) * rootBone.scaleY;
    rootBone.a = (pa * la + pb * lc) * self.scaleX;
    rootBone.b = (pa * lb + pb * ld) * self.scaleX;
    rootBone.c = (pc * la + pd * lc) * self.scaleY;
    rootBone.d = (pc * lb + pd * ld) * self.scaleY;
    for i = 0; i < internal.updateCacheCount; ++i {
        _spUpdate* update = internal.updateCache + i;
        switch update.type {
            case SP_UPDATE_BONE: {
                if cast(spBone*, update.object) != rootBone {
                    spBone_updateWorldTransform(cast(spBone*, update.object));
                }
            }
            case SP_UPDATE_IK_CONSTRAINT: {
                spIkConstraint_update(cast(spIkConstraint*, update.object));
            }
            case SP_UPDATE_TRANSFORM_CONSTRAINT: {
                spTransformConstraint_update(cast(spTransformConstraint*, update.object));
            }
            case SP_UPDATE_PATH_CONSTRAINT: {
                spPathConstraint_update(cast(spPathConstraint*, update.object));
            }
            case SP_UPDATE_PHYSICS_CONSTRAINT: {
                spPhysicsConstraint_update(cast(spPhysicsConstraint*, update.object), physics);
            }
        }
    }
}

void spSkeleton_setToSetupPose(spSkeleton* self) {
    spSkeleton_setBonesToSetupPose(self);
    spSkeleton_setSlotsToSetupPose(self);
}

void spSkeleton_setBonesToSetupPose(spSkeleton* self) {
    i32 i;
    for i = 0; i < self.bonesCount; ++i {
        spBone_setToSetupPose(self.bones[i]);
    }
    for i = 0; i < self.ikConstraintsCount; ++i {
        spIkConstraint_setToSetupPose(self.ikConstraints[i]);
    }
    for i = 0; i < self.transformConstraintsCount; ++i {
        spTransformConstraint_setToSetupPose(self.transformConstraints[i]);
    }
    for i = 0; i < self.pathConstraintsCount; ++i {
        spPathConstraint_setToSetupPose(self.pathConstraints[i]);
    }
    for i = 0; i < self.physicsConstraintsCount; ++i {
        spPhysicsConstraint_setToSetupPose(self.physicsConstraints[i]);
    }
}

void spSkeleton_setSlotsToSetupPose(spSkeleton* self) {
    i32 i;
    memcpy(self.drawOrder, self.slots, cast(u64, self.slotsCount * sizeof(spSlot*)));
    for i = 0; i < self.slotsCount; ++i {
        spSlot_setToSetupPose(self.slots[i]);
    }
}

spBone* spSkeleton_findBone(spSkeleton* self, u8* boneName) {
    i32 i;
    for i = 0; i < self.bonesCount; ++i {
        if strcmp(self.data.bones[i].name, boneName) == 0 {
            return self.bones[i];
        }
    }
    return null;
}

spSlot* spSkeleton_findSlot(spSkeleton* self, u8* slotName) {
    i32 i;
    for i = 0; i < self.slotsCount; ++i {
        if strcmp(self.data.slots[i].name, slotName) == 0 {
            return self.slots[i];
        }
    }
    return null;
}

i32 spSkeleton_setSkinByName(spSkeleton* self, u8* skinName) {
    spSkin* skin;
    if skinName == null {
        spSkeleton_setSkin(self, null);
        return 1;
    }
    skin = spSkeletonData_findSkin(self.data, skinName);
    if skin == null {
        return 0;
    }
    spSkeleton_setSkin(self, skin);
    return 1;
}

void spSkeleton_setSkin(spSkeleton* self, spSkin* newSkin) {
    if self.skin == newSkin {
        return;
    }
    if newSkin != null {
        if self.skin != null {
            spSkin_attachAll(newSkin, self, self.skin);
        } else {
            i32 i;
            for i = 0; i < self.slotsCount; ++i {
                spSlot* slot = self.slots[i];
                if slot.data.attachmentName != null {
                    spAttachment* attachment = spSkin_getAttachment(newSkin, i, slot.data.attachmentName);
                    if attachment != null {
                        spSlot_setAttachment(slot, attachment);
                    }
                }
            }
        }
    }
    self.skin = newSkin;
    spSkeleton_updateCache(self);
}

spAttachment* spSkeleton_getAttachmentForSlotName(spSkeleton* self, u8* slotName, u8* attachmentName) {
    i32 slotIndex = spSkeletonData_findSlot(self.data, slotName).index;
    return spSkeleton_getAttachmentForSlotIndex(self, slotIndex, attachmentName);
}

spAttachment* spSkeleton_getAttachmentForSlotIndex(spSkeleton* self, i32 slotIndex, u8* attachmentName) {
    if slotIndex == -1 {
        return null;
    }
    if self.skin != null {
        spAttachment* attachment = spSkin_getAttachment(self.skin, slotIndex, attachmentName);
        if attachment != null {
            return attachment;
        }
    }
    if self.data.defaultSkin != null {
        spAttachment* attachment = spSkin_getAttachment(self.data.defaultSkin, slotIndex, attachmentName);
        if attachment != null {
            return attachment;
        }
    }
    return null;
}

i32 spSkeleton_setAttachment(spSkeleton* self, u8* slotName, u8* attachmentName) {
    i32 i;
    for i = 0; i < self.slotsCount; ++i {
        spSlot* slot = self.slots[i];
        if strcmp(slot.data.name, slotName) == 0 {
            if attachmentName == null {
                spSlot_setAttachment(slot, null);
            } else {
                spAttachment* attachment = spSkeleton_getAttachmentForSlotIndex(self, i, attachmentName);
                if attachment == null {
                    return 0;
                }
                spSlot_setAttachment(slot, attachment);
            }
            return 1;
        }
    }
    return 0;
}

spIkConstraint* spSkeleton_findIkConstraint(spSkeleton* self, u8* constraintName) {
    i32 i;
    for i = 0; i < self.ikConstraintsCount; ++i {
        if strcmp(self.ikConstraints[i].data.name, constraintName) == 0 {
            return self.ikConstraints[i];
        }
    }
    return null;
}

spTransformConstraint* spSkeleton_findTransformConstraint(spSkeleton* self, u8* constraintName) {
    i32 i;
    for i = 0; i < self.transformConstraintsCount; ++i {
        if strcmp(self.transformConstraints[i].data.name, constraintName) == 0 {
            return self.transformConstraints[i];
        }
    }
    return null;
}

spPathConstraint* spSkeleton_findPathConstraint(spSkeleton* self, u8* constraintName) {
    i32 i;
    for i = 0; i < self.pathConstraintsCount; ++i {
        if strcmp(self.pathConstraints[i].data.name, constraintName) == 0 {
            return self.pathConstraints[i];
        }
    }
    return null;
}

spPhysicsConstraint* spSkeleton_findPhysicsConstraint(spSkeleton* self, u8* constraintName) {
    i32 i;
    for i = 0; i < self.physicsConstraintsCount; ++i {
        if strcmp(self.physicsConstraints[i].data.name, constraintName) == 0 {
            return self.physicsConstraints[i];
        }
    }
    return null;
}

void spSkeleton_physicsTranslate(spSkeleton* self, f32 x, f32 y) {
    for i32 i = 0; i < self.physicsConstraintsCount; i++ {
        spPhysicsConstraint_translate(self.physicsConstraints[i], x, y);
    }
}

void spSkeleton_physicsRotate(spSkeleton* self, f32 x, f32 y, f32 degrees) {
    for i32 i = 0; i < self.physicsConstraintsCount; i++ {
        spPhysicsConstraint_rotate(self.physicsConstraints[i], x, y, degrees);
    }
}

private {
i32 SkeletonBinary__string_starts_with(u8* str_var, u8* needle) {
    i32 lenStr;
    i32 lenNeedle;
    i32 i;
    if str_var == null {
        return 0;
    }
    lenStr = cast(i32, strlen(str_var));
    lenNeedle = cast(i32, strlen(needle));
    if lenStr < lenNeedle {
        return 0;
    }
    for i = 0; i < lenNeedle; i++ {
        if str_var[i] != needle[i] {
            return 0;
        }
    }
    return -1;
}

u8* string_copy(u8* str_var) {
    if str_var == null {
        return null;
    }
    var len = cast(i32, strlen(str_var));
    var tmp = cast(u8*, alloc(cast(i64, len + 1)));
    strncpy(tmp, str_var, cast(u64, len));
    tmp[len] = 0;
    return tmp;
}
}

spSkeletonBinary* spSkeletonBinary_createWithLoader(spAttachmentLoader* attachmentLoader) {
    spSkeletonBinary* self = &cast(_spSkeletonBinary*, _spCalloc(1, cast(u64, sizeof(_spSkeletonBinary)), "extension.h", 100)).super;
    self.scale = 1.0f;
    self.attachmentLoader = attachmentLoader;
    return self;
}

spSkeletonBinary* spSkeletonBinary_create(spAtlas* atlas) {
    spAtlasAttachmentLoader* attachmentLoader = spAtlasAttachmentLoader_create(atlas);
    spSkeletonBinary* self = spSkeletonBinary_createWithLoader(&attachmentLoader.super);
    cast(_spSkeletonBinary*, self).ownsLoader = 1;
    return self;
}

void spSkeletonBinary_dispose(spSkeletonBinary* self) {
    var internal = cast(_spSkeletonBinary*, self);
    if internal.ownsLoader != 0 {
        spAttachmentLoader_dispose(self.attachmentLoader);
    }
    _spFree(cast(void*, internal.linkedMeshes));
    _spFree(cast(void*, self.error));
    _spFree(cast(void*, self));
}

void _spSkeletonBinary_setError(spSkeletonBinary* self, u8* value1, u8* value2) {
    noinit u8[256] message;
    i32 length;
    _spFree(cast(void*, self.error));
    strcpy(message, value1);
    length = cast(i32, strlen(value1));
    if value2 != null {
        strncat(message + length, value2, cast(u64, 255 - length));
    }
    self.error = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(message) + 1), "extension.h", 97));
    strcpy(self.error, message);
}

private {
u8 readByte(_dataInput* input) {
    return *input.cursor++;
}

i8 readSByte(_dataInput* input) {
    return cast(i8, readByte(input));
}

i32 readBoolean(_dataInput* input) {
    return readByte(input) != 0;
}

i32 readInt(_dataInput* input) {
    u32 result = readByte(input);
    result <<= 8;
    result |= readByte(input);
    result <<= 8;
    result |= readByte(input);
    result <<= 8;
    result |= readByte(input);
    return cast(i32, result);
}

i32 readVarint(_dataInput* input, i32 optimizePositive) {
    u8 b = readByte(input);
    var value = cast(i32, b & 0x7F);
    if (b & 0x80) != 0 {
        b = readByte(input);
        value |= cast(i32, b & 0x7F) << 7;
        if (b & 0x80) != 0 {
            b = readByte(input);
            value |= cast(i32, b & 0x7F) << 14;
            if (b & 0x80) != 0 {
                b = readByte(input);
                value |= cast(i32, b & 0x7F) << 21;
                if (b & 0x80) != 0 {
                    value |= cast(i32, readByte(input) & 0x7F) << 28;
                }
            }
        }
    }
    if optimizePositive == 0 {
        value = cast(i32, cast(u32, value) >> 1 ^ cast(u32, -(value & 1)));
    }
    return value;
}
}

f32 readFloat(_dataInput* input) {
    intToFloat_t intToFloat;
    intToFloat.intValue = readInt(input);
    return intToFloat.floatValue;
}

u8* readString(_dataInput* input) {
    i32 length = readVarint(input, 1);
    u8* string_var;  // renamed from: string
    if length == 0 {
        return null;
    }
    string_var = cast(u8*, _spMalloc(cast(u64, sizeof(u8) * length), "extension.h", 97));
    memcpy(string_var, input.cursor, cast(u64, length - 1));
    input.cursor += length - 1;
    string_var[length - 1] = 0;
    return string_var;
}

private {
u8* readStringRef(_dataInput* input, spSkeletonData* skeletonData) {
    i32 index = readVarint(input, 1);
    return index == 0 ? null : skeletonData.strings[index - 1];
}

void readColor(_dataInput* input, f32* r, f32* g, f32* b, f32* a) {
    *r = cast(f32, readByte(input)) / 255.0f;
    *g = cast(f32, readByte(input)) / 255.0f;
    *b = cast(f32, readByte(input)) / 255.0f;
    *a = cast(f32, readByte(input)) / 255.0f;
}

spSequence* SkeletonBinary__readSequence(_dataInput* input) {
    spSequence* sequence = spSequence_create(readVarint(input, -1));
    sequence.start = readVarint(input, -1);
    sequence.digits = readVarint(input, -1);
    sequence.setupIndex = readVarint(input, -1);
    return sequence;
}

void SkeletonBinary__setBezier(_dataInput* input, spTimeline* timeline, i32 bezier, i32 frame, i32 value, f32 time1, f32 time2, f32 value1, f32 value2, f32 scale) {
    f32 cx1 = readFloat(input);
    f32 cy1 = readFloat(input);
    f32 cx2 = readFloat(input);
    f32 cy2 = readFloat(input);
    spTimeline_setBezier(timeline, bezier, frame, cast(f32, value), time1, value1, cx1, cy1 * scale, cx2, cy2 * scale, time2, value2);
}

void SkeletonBinary__readTimeline(_dataInput* input, spTimelineArray* timelines, spCurveTimeline1* timeline, f32 scale) {
    i32 frame;
    i32 bezier;
    i32 frameLast;
    f32 time2;
    f32 value2;
    f32 time = readFloat(input);
    f32 value = readFloat(input) * scale;
    {
        frame = 0;
        bezier = 0;
        for frameLast = timeline.super.frameCount - 1; true; frame++ {
            spCurveTimeline1_setFrame(timeline, frame, time, value);
            if frame == frameLast {
                break;
            }
            time2 = readFloat(input);
            value2 = readFloat(input) * scale;
            switch readSByte(input) {
                case 1: {
                    spCurveTimeline_setStepped(timeline, frame);
                }
                case 2: {
                    SkeletonBinary__setBezier(input, &timeline.super, bezier++, frame, 0, time, time2, value, value2, scale);
                }
            }
            time = time2;
            value = value2;
        }
    }
    spTimelineArray_add(timelines, &timeline.super);
}

void SkeletonBinary__readTimeline2(_dataInput* input, spTimelineArray* timelines, spCurveTimeline2* timeline, f32 scale) {
    i32 frame;
    i32 bezier;
    i32 frameLast;
    f32 time2;
    f32 nvalue1;
    f32 nvalue2;
    f32 time = readFloat(input);
    f32 value1 = readFloat(input) * scale;
    f32 value2 = readFloat(input) * scale;
    {
        frame = 0;
        bezier = 0;
        for frameLast = timeline.super.frameCount - 1; true; frame++ {
            spCurveTimeline2_setFrame(timeline, frame, time, value1, value2);
            if frame == frameLast {
                break;
            }
            time2 = readFloat(input);
            nvalue1 = readFloat(input) * scale;
            nvalue2 = readFloat(input) * scale;
            switch readSByte(input) {
                case 1: {
                    spCurveTimeline_setStepped(timeline, frame);
                }
                case 2: {
                    SkeletonBinary__setBezier(input, &timeline.super, bezier++, frame, 0, time, time2, value1, nvalue1, scale);
                    SkeletonBinary__setBezier(input, &timeline.super, bezier++, frame, 1, time, time2, value2, nvalue2, scale);
                }
            }
            time = time2;
            value1 = nvalue1;
            value2 = nvalue2;
        }
    }
    spTimelineArray_add(timelines, &timeline.super);
}

void _spSkeletonBinary_addLinkedMesh(spSkeletonBinary* self, spMeshAttachment* mesh, i32 skinIndex, i32 slotIndex, u8* parent, i32 inheritDeform) {
    _spLinkedMeshBinary* linkedMesh;
    var internal = cast(_spSkeletonBinary*, self);
    if internal.linkedMeshCount == internal.linkedMeshCapacity {
        _spLinkedMeshBinary* linkedMeshes;
        internal.linkedMeshCapacity *= 2;
        if internal.linkedMeshCapacity < 8 {
            internal.linkedMeshCapacity = 8;
        }
        linkedMeshes = cast(_spLinkedMeshBinary*, _spMalloc(cast(u64, sizeof(_spLinkedMeshBinary) * internal.linkedMeshCapacity), "extension.h", 97));
        memcpy(linkedMeshes, internal.linkedMeshes, cast(u64, sizeof(_spLinkedMeshBinary) * internal.linkedMeshCount));
        _spFree(cast(void*, internal.linkedMeshes));
        internal.linkedMeshes = linkedMeshes;
    }
    linkedMesh = internal.linkedMeshes + internal.linkedMeshCount++;
    linkedMesh.mesh = mesh;
    linkedMesh.skinIndex = skinIndex;
    linkedMesh.slotIndex = slotIndex;
    linkedMesh.parent = parent;
    linkedMesh.inheritTimeline = inheritDeform;
}

spAnimation* _spSkeletonBinary_readAnimation(spSkeletonBinary* self, u8* name, _dataInput* input, spSkeletonData* skeletonData) {
    spTimelineArray* timelines = spTimelineArray_create(18);
    f32 duration = 0.0f;
    i32 i;
    i32 n;
    i32 ii;
    i32 nn;
    i32 iii;
    i32 nnn;
    i32 frame;
    i32 bezier;
    i32 drawOrderCount;
    i32 eventCount;
    spAnimation* animation;
    f32 scale = self.scale;
    i32 numTimelines = readVarint(input, 1);
    ignore numTimelines;
    {
        i = 0;
        for n = readVarint(input, 1); i < n; ++i {
            i32 slotIndex = readVarint(input, 1);
            {
                ii = 0;
                for nn = readVarint(input, 1); ii < nn; ++ii {
                    u8 timelineType = readByte(input);
                    i32 frameCount = readVarint(input, 1);
                    i32 frameLast = frameCount - 1;
                    switch timelineType {
                        case 0: {
                            {
                                spAttachmentTimeline* timeline = spAttachmentTimeline_create(frameCount, slotIndex);
                                for frame = 0; frame < frameCount; ++frame {
                                    f32 time = readFloat(input);
                                    u8* attachmentName = readStringRef(input, skeletonData);
                                    spAttachmentTimeline_setFrame(timeline, frame, time, attachmentName);
                                }
                                spTimelineArray_add(timelines, &timeline.super);
                                break case;
                            }
                        }
                        case 1: {
                            {
                                i32 bezierCount = readVarint(input, 1);
                                spRGBATimeline* timeline = spRGBATimeline_create(frameCount, bezierCount, slotIndex);
                                f32 time = readFloat(input);
                                var r = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var g = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var b = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var a = cast(f32, cast(f64, readByte(input)) / 255.0);
                                {
                                    frame = 0;
                                    for bezier = 0; true; frame++ {
                                        f32 time2;
                                        f32 r2;
                                        f32 g2;
                                        f32 b2;
                                        f32 a2;
                                        spRGBATimeline_setFrame(timeline, frame, time, r, g, b, a);
                                        if frame == frameLast {
                                            break;
                                        }
                                        time2 = readFloat(input);
                                        r2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        g2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        b2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        a2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        switch readSByte(input) {
                                            case 1: {
                                                spCurveTimeline_setStepped(&timeline.super, frame);
                                            }
                                            case 2: {
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 0, time, time2, r, r2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 1, time, time2, g, g2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 2, time, time2, b, b2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 3, time, time2, a, a2, 1.0f);
                                            }
                                        }
                                        time = time2;
                                        r = r2;
                                        g = g2;
                                        b = b2;
                                        a = a2;
                                    }
                                }
                                spTimelineArray_add(timelines, &timeline.super.super);
                                break case;
                            }
                        }
                        case 2: {
                            {
                                i32 bezierCount = readVarint(input, 1);
                                spRGBTimeline* timeline = spRGBTimeline_create(frameCount, bezierCount, slotIndex);
                                f32 time = readFloat(input);
                                var r = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var g = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var b = cast(f32, cast(f64, readByte(input)) / 255.0);
                                {
                                    frame = 0;
                                    for bezier = 0; true; frame++ {
                                        f32 time2;
                                        f32 r2;
                                        f32 g2;
                                        f32 b2;
                                        spRGBTimeline_setFrame(timeline, frame, time, r, g, b);
                                        if frame == frameLast {
                                            break;
                                        }
                                        time2 = readFloat(input);
                                        r2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        g2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        b2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        switch readSByte(input) {
                                            case 1: {
                                                spCurveTimeline_setStepped(&timeline.super, frame);
                                            }
                                            case 2: {
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 0, time, time2, r, r2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 1, time, time2, g, g2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 2, time, time2, b, b2, 1.0f);
                                            }
                                        }
                                        time = time2;
                                        r = r2;
                                        g = g2;
                                        b = b2;
                                    }
                                }
                                spTimelineArray_add(timelines, &timeline.super.super);
                                break case;
                            }
                        }
                        case 3: {
                            {
                                i32 bezierCount = readVarint(input, 1);
                                spRGBA2Timeline* timeline = spRGBA2Timeline_create(frameCount, bezierCount, slotIndex);
                                f32 time = readFloat(input);
                                var r = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var g = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var b = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var a = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var r2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var g2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var b2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                {
                                    frame = 0;
                                    for bezier = 0; true; frame++ {
                                        f32 time2;
                                        f32 nr;
                                        f32 ng;
                                        f32 nb;
                                        f32 na;
                                        f32 nr2;
                                        f32 ng2;
                                        f32 nb2;
                                        spRGBA2Timeline_setFrame(timeline, frame, time, r, g, b, a, r2, g2, b2);
                                        if frame == frameLast {
                                            break;
                                        }
                                        time2 = readFloat(input);
                                        nr = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        ng = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        nb = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        na = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        nr2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        ng2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        nb2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        switch readSByte(input) {
                                            case 1: {
                                                spCurveTimeline_setStepped(&timeline.super, frame);
                                            }
                                            case 2: {
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 0, time, time2, r, nr, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 1, time, time2, g, ng, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 2, time, time2, b, nb, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 3, time, time2, a, na, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 4, time, time2, r2, nr2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 5, time, time2, g2, ng2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 6, time, time2, b2, nb2, 1.0f);
                                            }
                                        }
                                        time = time2;
                                        r = nr;
                                        g = ng;
                                        b = nb;
                                        a = na;
                                        r2 = nr2;
                                        g2 = ng2;
                                        b2 = nb2;
                                    }
                                }
                                spTimelineArray_add(timelines, &timeline.super.super);
                                break case;
                            }
                        }
                        case 4: {
                            {
                                i32 bezierCount = readVarint(input, 1);
                                spRGB2Timeline* timeline = spRGB2Timeline_create(frameCount, bezierCount, slotIndex);
                                f32 time = readFloat(input);
                                var r = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var g = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var b = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var r2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var g2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                var b2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                {
                                    frame = 0;
                                    for bezier = 0; true; frame++ {
                                        f32 time2;
                                        f32 nr;
                                        f32 ng;
                                        f32 nb;
                                        f32 nr2;
                                        f32 ng2;
                                        f32 nb2;
                                        spRGB2Timeline_setFrame(timeline, frame, time, r, g, b, r2, g2, b2);
                                        if frame == frameLast {
                                            break;
                                        }
                                        time2 = readFloat(input);
                                        nr = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        ng = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        nb = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        nr2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        ng2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        nb2 = cast(f32, cast(f64, readByte(input)) / 255.0);
                                        switch readSByte(input) {
                                            case 1: {
                                                spCurveTimeline_setStepped(&timeline.super, frame);
                                            }
                                            case 2: {
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 0, time, time2, r, nr, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 1, time, time2, g, ng, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 2, time, time2, b, nb, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 3, time, time2, r2, nr2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 4, time, time2, g2, ng2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 5, time, time2, b2, nb2, 1.0f);
                                            }
                                        }
                                        time = time2;
                                        r = nr;
                                        g = ng;
                                        b = nb;
                                        r2 = nr2;
                                        g2 = ng2;
                                        b2 = nb2;
                                    }
                                }
                                spTimelineArray_add(timelines, &timeline.super.super);
                                break case;
                            }
                        }
                        case 5: {
                            {
                                i32 bezierCount = readVarint(input, 1);
                                spAlphaTimeline* timeline = spAlphaTimeline_create(frameCount, bezierCount, slotIndex);
                                f32 time = readFloat(input);
                                var a = cast(f32, cast(f64, readByte(input)) / 255.0);
                                {
                                    frame = 0;
                                    for bezier = 0; true; frame++ {
                                        f32 time2;
                                        f32 a2;
                                        spAlphaTimeline_setFrame(timeline, frame, time, a);
                                        if frame == frameLast {
                                            break;
                                        }
                                        time2 = readFloat(input);
                                        a2 = cast(f32, readByte(input) / 255);
                                        switch readSByte(input) {
                                            case 1: {
                                                spCurveTimeline_setStepped(&timeline.super, frame);
                                            }
                                            case 2: {
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 0, time, time2, a, a2, 1.0f);
                                            }
                                        }
                                        time = time2;
                                        a = a2;
                                    }
                                }
                                spTimelineArray_add(timelines, &timeline.super.super);
                                break case;
                            }
                        }
                        default: {
                            {
                                return null;
                            }
                        }
                    }
                }
            }
        }
    }
    {
        i = 0;
        for n = readVarint(input, 1); i < n; ++i {
            i32 boneIndex = readVarint(input, 1);
            {
                ii = 0;
                for nn = readVarint(input, 1); ii < nn; ++ii {
                    u8 timelineType = readByte(input);
                    i32 frameCount = readVarint(input, 1);
                    if timelineType == 10 {
                        spInheritTimeline* timeline = spInheritTimeline_create(frameCount, boneIndex);
                        for frame = 0; frame < frameCount; frame++ {
                            f32 time = readFloat(input);
                            var inherit = cast(spInherit, readByte(input));
                            spInheritTimeline_setFrame(timeline, frame, time, inherit);
                        }
                        spTimelineArray_add(timelines, &timeline.super);
                        continue;
                    }
                    i32 bezierCount = readVarint(input, 1);
                    switch timelineType {
                        case 0: {
                            SkeletonBinary__readTimeline(input, timelines, &spRotateTimeline_create(frameCount, bezierCount, boneIndex).super, 1.0f);
                        }
                        case 1: {
                            SkeletonBinary__readTimeline2(input, timelines, &spTranslateTimeline_create(frameCount, bezierCount, boneIndex).super, scale);
                        }
                        case 2: {
                            SkeletonBinary__readTimeline(input, timelines, &spTranslateXTimeline_create(frameCount, bezierCount, boneIndex).super, scale);
                        }
                        case 3: {
                            SkeletonBinary__readTimeline(input, timelines, &spTranslateYTimeline_create(frameCount, bezierCount, boneIndex).super, scale);
                        }
                        case 4: {
                            SkeletonBinary__readTimeline2(input, timelines, &spScaleTimeline_create(frameCount, bezierCount, boneIndex).super, 1.0f);
                        }
                        case 5: {
                            SkeletonBinary__readTimeline(input, timelines, &spScaleXTimeline_create(frameCount, bezierCount, boneIndex).super, 1.0f);
                        }
                        case 6: {
                            SkeletonBinary__readTimeline(input, timelines, &spScaleYTimeline_create(frameCount, bezierCount, boneIndex).super, 1.0f);
                        }
                        case 7: {
                            SkeletonBinary__readTimeline2(input, timelines, &spShearTimeline_create(frameCount, bezierCount, boneIndex).super, 1.0f);
                        }
                        case 8: {
                            SkeletonBinary__readTimeline(input, timelines, &spShearXTimeline_create(frameCount, bezierCount, boneIndex).super, 1.0f);
                        }
                        case 9: {
                            SkeletonBinary__readTimeline(input, timelines, &spShearYTimeline_create(frameCount, bezierCount, boneIndex).super, 1.0f);
                        }
                        default: {
                            {
                                for iii = 0; iii < timelines.size; ++iii {
                                    spTimeline_dispose(timelines.items[iii]);
                                }
                                spTimelineArray_dispose(timelines);
                                _spSkeletonBinary_setError(self, "Invalid timeline type for a bone: ", skeletonData.bones[boneIndex].name);
                                return null;
                            }
                        }
                    }
                }
            }
        }
    }
    {
        i = 0;
        for n = readVarint(input, 1); i < n; ++i {
            i32 index = readVarint(input, 1);
            i32 frameCount = readVarint(input, 1);
            i32 frameLast = frameCount - 1;
            i32 bezierCount = readVarint(input, 1);
            spIkConstraintTimeline* timeline = spIkConstraintTimeline_create(frameCount, bezierCount, index);
            var flags = cast(i32, readByte(input));
            f32 time = readFloat(input);
            f32 mix = (flags & 1) != 0 ? (flags & 2) != 0 ? readFloat(input) : 1.0f : 0;
            f32 softness = (flags & 4) != 0 ? readFloat(input) * scale : 0.0f;
            {
                frame = 0;
                for bezier = 0; true; frame++ {
                    spIkConstraintTimeline_setFrame(timeline, frame, time, mix, softness, (flags & 8) != 0 ? 1 : -1, cast(i32, (flags & 16) != 0), cast(i32, (flags & 32) != 0));
                    if frame == frameLast {
                        break;
                    }
                    flags = cast(i32, readByte(input));
                    f32 time2 = readFloat(input);
                    f32 mix2 = (flags & 1) != 0 ? (flags & 2) != 0 ? readFloat(input) : 1.0f : 0;
                    f32 softness2 = (flags & 4) != 0 ? readFloat(input) * scale : 0.0f;
                    if (flags & 64) != 0 {
                        spCurveTimeline_setStepped(&timeline.super, frame);
                    } else if (flags & 128) != 0 {
                        SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 0, time, time2, mix, mix2, 1.0f);
                        SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 1, time, time2, softness, softness2, scale);
                    }
                    time = time2;
                    mix = mix2;
                    softness = softness2;
                }
            }
            spTimelineArray_add(timelines, &timeline.super.super);
        }
    }
    {
        i = 0;
        for n = readVarint(input, 1); i < n; ++i {
            i32 index = readVarint(input, 1);
            i32 frameCount = readVarint(input, 1);
            i32 frameLast = frameCount - 1;
            i32 bezierCount = readVarint(input, 1);
            spTransformConstraintTimeline* timeline = spTransformConstraintTimeline_create(frameCount, bezierCount, index);
            f32 time = readFloat(input);
            f32 mixRotate = readFloat(input);
            f32 mixX = readFloat(input);
            f32 mixY = readFloat(input);
            f32 mixScaleX = readFloat(input);
            f32 mixScaleY = readFloat(input);
            f32 mixShearY = readFloat(input);
            {
                frame = 0;
                for bezier = 0; true; frame++ {
                    f32 time2;
                    f32 mixRotate2;
                    f32 mixX2;
                    f32 mixY2;
                    f32 mixScaleX2;
                    f32 mixScaleY2;
                    f32 mixShearY2;
                    spTransformConstraintTimeline_setFrame(timeline, frame, time, mixRotate, mixX, mixY, mixScaleX, mixScaleY, mixShearY);
                    if frame == frameLast {
                        break;
                    }
                    time2 = readFloat(input);
                    mixRotate2 = readFloat(input);
                    mixX2 = readFloat(input);
                    mixY2 = readFloat(input);
                    mixScaleX2 = readFloat(input);
                    mixScaleY2 = readFloat(input);
                    mixShearY2 = readFloat(input);
                    switch readSByte(input) {
                        case 1: {
                            spCurveTimeline_setStepped(&timeline.super, frame);
                        }
                        case 2: {
                            SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 0, time, time2, mixRotate, mixRotate2, 1.0f);
                            SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 1, time, time2, mixX, mixX2, 1.0f);
                            SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 2, time, time2, mixY, mixY2, 1.0f);
                            SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 3, time, time2, mixScaleX, mixScaleX2, 1.0f);
                            SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 4, time, time2, mixScaleY, mixScaleY2, 1.0f);
                            SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 5, time, time2, mixShearY, mixShearY2, 1.0f);
                        }
                    }
                    time = time2;
                    mixRotate = mixRotate2;
                    mixX = mixX2;
                    mixY = mixY2;
                    mixScaleX = mixScaleX2;
                    mixScaleY = mixScaleY2;
                    mixShearY = mixShearY2;
                }
            }
            spTimelineArray_add(timelines, &timeline.super.super);
        }
    }
    {
        i = 0;
        for n = readVarint(input, 1); i < n; ++i {
            i32 index = readVarint(input, 1);
            spPathConstraintData* data = skeletonData.pathConstraints[index];
            {
                ii = 0;
                for nn = readVarint(input, 1); ii < nn; ++ii {
                    var type = cast(i32, readByte(input));
                    i32 frameCount = readVarint(input, 1);
                    i32 bezierCount = readVarint(input, 1);
                    switch type {
                        case 0: {
                            {
                                SkeletonBinary__readTimeline(input, timelines, &spPathConstraintPositionTimeline_create(frameCount, bezierCount, index).super, data.positionMode == SP_POSITION_MODE_FIXED ? scale : 1.0f);
                                break case;
                            }
                        }
                        case 1: {
                            {
                                SkeletonBinary__readTimeline(input, timelines, &spPathConstraintSpacingTimeline_create(frameCount, bezierCount, index).super, data.spacingMode == SP_SPACING_MODE_LENGTH || data.spacingMode == SP_SPACING_MODE_FIXED ? scale : 1.0f);
                                break case;
                            }
                        }
                        case 2: {
                            {
                                f32 time;
                                f32 mixRotate;
                                f32 mixX;
                                f32 mixY;
                                i32 frameLast;
                                spPathConstraintMixTimeline* timeline = spPathConstraintMixTimeline_create(frameCount, bezierCount, index);
                                time = readFloat(input);
                                mixRotate = readFloat(input);
                                mixX = readFloat(input);
                                mixY = readFloat(input);
                                {
                                    frame = 0;
                                    bezier = 0;
                                    for frameLast = timeline.super.super.frameCount - 1; true; frame++ {
                                        f32 time2;
                                        f32 mixRotate2;
                                        f32 mixX2;
                                        f32 mixY2;
                                        spPathConstraintMixTimeline_setFrame(timeline, frame, time, mixRotate, mixX, mixY);
                                        if frame == frameLast {
                                            break;
                                        }
                                        time2 = readFloat(input);
                                        mixRotate2 = readFloat(input);
                                        mixX2 = readFloat(input);
                                        mixY2 = readFloat(input);
                                        switch readSByte(input) {
                                            case 1: {
                                                spCurveTimeline_setStepped(&timeline.super, frame);
                                            }
                                            case 2: {
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 0, time, time2, mixRotate, mixRotate2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 1, time, time2, mixX, mixX2, 1.0f);
                                                SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 2, time, time2, mixY, mixY2, 1.0f);
                                            }
                                        }
                                        time = time2;
                                        mixRotate = mixRotate2;
                                        mixX = mixX2;
                                        mixY = mixY2;
                                    }
                                }
                                spTimelineArray_add(timelines, &timeline.super.super);
                            }
                        }
                    }
                }
            }
        }
    }
    {
        i = 0;
        for n = readVarint(input, 1); i < n; i++ {
            i32 index = readVarint(input, 1) - 1;
            {
                ii = 0;
                for nn = readVarint(input, 1); ii < nn; ii++ {
                    var type = cast(i32, readByte(input));
                    i32 frameCount = readVarint(input, 1);
                    if type == 8 {
                        spPhysicsConstraintResetTimeline* timeline = spPhysicsConstraintResetTimeline_create(frameCount, index);
                        for frame = 0; frame < frameCount; frame++ {
                            spPhysicsConstraintResetTimeline_setFrame(timeline, frame, readFloat(input));
                        }
                        spTimelineArray_add(timelines, &timeline.super);
                        continue;
                    }
                    i32 bezierCount = readVarint(input, 1);
                    switch type {
                        case 0: {
                            SkeletonBinary__readTimeline(input, timelines, &spPhysicsConstraintTimeline_create(frameCount, bezierCount, index, SP_TIMELINE_PHYSICSCONSTRAINT_INERTIA).super, 1.0f);
                        }
                        case 1: {
                            SkeletonBinary__readTimeline(input, timelines, &spPhysicsConstraintTimeline_create(frameCount, bezierCount, index, SP_TIMELINE_PHYSICSCONSTRAINT_STRENGTH).super, 1.0f);
                        }
                        case 2: {
                            SkeletonBinary__readTimeline(input, timelines, &spPhysicsConstraintTimeline_create(frameCount, bezierCount, index, SP_TIMELINE_PHYSICSCONSTRAINT_DAMPING).super, 1.0f);
                        }
                        case 4: {
                            SkeletonBinary__readTimeline(input, timelines, &spPhysicsConstraintTimeline_create(frameCount, bezierCount, index, SP_TIMELINE_PHYSICSCONSTRAINT_MASS).super, 1.0f);
                        }
                        case 5: {
                            SkeletonBinary__readTimeline(input, timelines, &spPhysicsConstraintTimeline_create(frameCount, bezierCount, index, SP_TIMELINE_PHYSICSCONSTRAINT_WIND).super, 1.0f);
                        }
                        case 6: {
                            SkeletonBinary__readTimeline(input, timelines, &spPhysicsConstraintTimeline_create(frameCount, bezierCount, index, SP_TIMELINE_PHYSICSCONSTRAINT_GRAVITY).super, 1.0f);
                        }
                        case 7: {
                            SkeletonBinary__readTimeline(input, timelines, &spPhysicsConstraintTimeline_create(frameCount, bezierCount, index, SP_TIMELINE_PHYSICSCONSTRAINT_MIX).super, 1.0f);
                        }
                    }
                }
            }
        }
    }
    {
        i = 0;
        for n = readVarint(input, 1); i < n; ++i {
            spSkin* skin = skeletonData.skins[readVarint(input, 1)];
            {
                ii = 0;
                for nn = readVarint(input, 1); ii < nn; ++ii {
                    i32 slotIndex = readVarint(input, 1);
                    {
                        iii = 0;
                        for nnn = readVarint(input, 1); iii < nnn; ++iii {
                            i32 frameCount;
                            i32 frameLast;
                            i32 bezierCount;
                            f32 time;
                            f32 time2;
                            u32 timelineType;
                            u8* attachmentName = readStringRef(input, skeletonData);
                            var attachment = cast(spVertexAttachment*, spSkin_getAttachment(skin, slotIndex, attachmentName));
                            if attachment == null {
                                for i = 0; i < timelines.size; ++i {
                                    spTimeline_dispose(timelines.items[i]);
                                }
                                spTimelineArray_dispose(timelines);
                                _spSkeletonBinary_setError(self, "Attachment not found: ", attachmentName);
                                return null;
                            }
                            timelineType = readByte(input);
                            frameCount = readVarint(input, 1);
                            frameLast = frameCount - 1;
                            switch timelineType {
                                case 0: {
                                    {
                                        f32* tempDeform;
                                        i32 weighted;
                                        i32 deformLength;
                                        spDeformTimeline* timeline;
                                        weighted = attachment.bones != null;
                                        deformLength = weighted != 0 ? attachment.verticesCount / 3 * 2 : attachment.verticesCount;
                                        tempDeform = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * deformLength), "extension.h", 97));
                                        bezierCount = readVarint(input, 1);
                                        timeline = spDeformTimeline_create(frameCount, deformLength, bezierCount, slotIndex, attachment);
                                        time = readFloat(input);
                                        {
                                            frame = 0;
                                            for bezier = 0; true; ++frame {
                                                f32* deform;
                                                i32 end = readVarint(input, 1);
                                                if end == 0 {
                                                    if weighted != 0 {
                                                        deform = tempDeform;
                                                        memset(deform, 0, cast(u64, sizeof(f32) * deformLength));
                                                    } else {
                                                        deform = attachment.vertices;
                                                    }
                                                } else {
                                                    i32 v;
                                                    i32 start = readVarint(input, 1);
                                                    deform = tempDeform;
                                                    memset(deform, 0, cast(u64, sizeof(f32) * start));
                                                    end += start;
                                                    if self.scale == 1.0f {
                                                        for v = start; v < end; ++v {
                                                            deform[v] = readFloat(input);
                                                        }
                                                    } else {
                                                        for v = start; v < end; ++v {
                                                            deform[v] = readFloat(input) * self.scale;
                                                        }
                                                    }
                                                    memset(deform + v, 0, cast(u64, sizeof(f32) * (deformLength - v)));
                                                    if weighted == 0 {
                                                        f32* vertices = attachment.vertices;
                                                        for v = 0; v < deformLength; ++v {
                                                            deform[v] += vertices[v];
                                                        }
                                                    }
                                                }
                                                spDeformTimeline_setFrame(timeline, frame, time, deform);
                                                if frame == frameLast {
                                                    break;
                                                }
                                                time2 = readFloat(input);
                                                switch readSByte(input) {
                                                    case 1: {
                                                        spCurveTimeline_setStepped(&timeline.super, frame);
                                                    }
                                                    case 2: {
                                                        SkeletonBinary__setBezier(input, &timeline.super.super, bezier++, frame, 0, time, time2, 0.0f, 1.0f, 1.0f);
                                                    }
                                                }
                                                time = time2;
                                            }
                                        }
                                        _spFree(cast(void*, tempDeform));
                                        spTimelineArray_add(timelines, cast(spTimeline*, timeline));
                                        break case;
                                    }
                                }
                                case 1: {
                                    {
                                        i32 modeAndIndex;
                                        f32 delay;
                                        spSequenceTimeline* timeline = spSequenceTimeline_create(frameCount, slotIndex, cast(spAttachment*, attachment));
                                        for frame = 0; frame < frameCount; frame++ {
                                            time = readFloat(input);
                                            modeAndIndex = readInt(input);
                                            delay = readFloat(input);
                                            spSequenceTimeline_setFrame(timeline, frame, time, modeAndIndex & 0xf, modeAndIndex >> 4, delay);
                                        }
                                        spTimelineArray_add(timelines, cast(spTimeline*, timeline));
                                        break case;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    drawOrderCount = readVarint(input, 1);
    if drawOrderCount != 0 {
        spDrawOrderTimeline* timeline = spDrawOrderTimeline_create(drawOrderCount, skeletonData.slotsCount);
        for i = 0; i < drawOrderCount; ++i {
            f32 time = readFloat(input);
            i32 offsetCount = readVarint(input, 1);
            var drawOrder = cast(i32*, _spMalloc(cast(u64, sizeof(i32) * skeletonData.slotsCount), "extension.h", 97));
            var unchanged = cast(i32*, _spMalloc(cast(u64, sizeof(i32) * (skeletonData.slotsCount - offsetCount)), "extension.h", 97));
            i32 originalIndex = 0;
            i32 unchangedIndex = 0;
            memset(drawOrder, -1, cast(u64, sizeof(i32) * skeletonData.slotsCount));
            for ii = 0; ii < offsetCount; ++ii {
                i32 slotIndex = readVarint(input, 1);
                while originalIndex != slotIndex {
                    unchanged[unchangedIndex++] = originalIndex++;
                }
                drawOrder[originalIndex + readVarint(input, 1)] = originalIndex;
                ++originalIndex;
            }
            while originalIndex < skeletonData.slotsCount {
                unchanged[unchangedIndex++] = originalIndex++;
            }
            for ii = skeletonData.slotsCount - 1; ii >= 0; ii-- {
                if drawOrder[ii] == -1 {
                    drawOrder[ii] = unchanged[--unchangedIndex];
                }
            }
            _spFree(cast(void*, unchanged));
            spDrawOrderTimeline_setFrame(timeline, i, time, drawOrder);
            _spFree(cast(void*, drawOrder));
        }
        spTimelineArray_add(timelines, cast(spTimeline*, timeline));
    }
    eventCount = readVarint(input, 1);
    if eventCount != 0 {
        spEventTimeline* timeline = spEventTimeline_create(eventCount);
        for i = 0; i < eventCount; ++i {
            f32 time = readFloat(input);
            spEventData* eventData = skeletonData.events[readVarint(input, 1)];
            spEvent* event = spEvent_create(time, eventData);
            event.intValue = readVarint(input, 0);
            event.floatValue = readFloat(input);
            u8* event_stringValue = readString(input);
            if event_stringValue == null {
                event.stringValue = string_copy(eventData.stringValue);
            } else {
                event.stringValue = string_copy(event_stringValue);
                _spFree(cast(void*, event_stringValue));
            }
            if eventData.audioPath != null {
                event.volume = readFloat(input);
                event.balance = readFloat(input);
            }
            spEventTimeline_setFrame(timeline, i, event);
        }
        spTimelineArray_add(timelines, cast(spTimeline*, timeline));
    }
    duration = 0.0f;
    {
        i = 0;
        for n = timelines.size; i < n; i++ {
            duration = duration > spTimeline_getDuration(timelines.items[i]) ? duration : spTimeline_getDuration(timelines.items[i]);
        }
    }
    animation = spAnimation_create(name, timelines, duration);
    return animation;
}

f32* _readFloatArray(_dataInput* input, i32 n, f32 scale) {
    var array = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * n), "extension.h", 97));
    i32 i;
    if scale == 1.0f {
        for i = 0; i < n; ++i {
            array[i] = readFloat(input);
        }
    } else {
        for i = 0; i < n; ++i {
            array[i] = readFloat(input) * scale;
        }
    }
    return array;
}

u16* _readShortArray(_dataInput* input, i32 n) {
    var array = cast(u16*, _spMalloc(cast(u64, sizeof(u16) * n), "extension.h", 97));
    i32 i;
    for i = 0; i < n; ++i {
        array[i] = cast(u16, readVarint(input, 1));
    }
    return array;
}

i32 SkeletonBinary___readVertices(_dataInput* input, f32** vertices, i32* verticesLength, i32** bones, i32* bonesCount, i32 weighted, f32 scale) {
    i32 vertexCount = readVarint(input, 1);
    *verticesLength = vertexCount << 1;
    if weighted == 0 {
        *vertices = _readFloatArray(input, *verticesLength, scale);
        *bones = null;
        *bonesCount = 0;
        return *verticesLength;
    }
    var v = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * (*verticesLength * 3 * 3)), "extension.h", 97));
    var b = cast(i32*, _spMalloc(cast(u64, sizeof(i32) * (*verticesLength * 3)), "extension.h", 97));
    i32 boneIdx = 0;
    i32 vertexIdx = 0;
    for i32 i = 0; i < vertexCount; ++i {
        i32 boneCount = readVarint(input, 1);
        b[boneIdx++] = boneCount;
        for i32 ii = 0; ii < boneCount; ++ii {
            b[boneIdx++] = readVarint(input, 1);
            v[vertexIdx++] = readFloat(input) * scale;
            v[vertexIdx++] = readFloat(input) * scale;
            v[vertexIdx++] = readFloat(input);
        }
    }
    *vertices = v;
    *bones = b;
    *bonesCount = boneIdx;
    *verticesLength = vertexIdx;
    return vertexCount << 1;
}
}

spAttachment* spSkeletonBinary_readAttachment(spSkeletonBinary* self, _dataInput* input, spSkin* skin, i32 slotIndex, u8* attachmentName, spSkeletonData* skeletonData, i32 nonessential) {
    var flags = cast(i32, readByte(input));
    u8* name = (flags & 8) != 0 ? readStringRef(input, skeletonData) : attachmentName;
    var type = cast(spAttachmentType, flags & 0x7);
    switch type {
        case SP_ATTACHMENT_REGION: {
            {
                u8* path = (flags & 16) != 0 ? readStringRef(input, skeletonData) : name;
                path = string_copy(path);
                noinit spColor color;
                spColor_setFromFloats(&color, 1.0f, 1.0f, 1.0f, 1.0f);
                if (flags & 32) != 0 {
                    readColor(input, &color.r, &color.g, &color.b, &color.a);
                }
                spSequence* sequence = (flags & 64) != 0 ? SkeletonBinary__readSequence(input) : null;
                f32 rotation = (flags & 128) != 0 ? readFloat(input) : 0.0f;
                f32 x = readFloat(input) * self.scale;
                f32 y = readFloat(input) * self.scale;
                f32 scaleX = readFloat(input);
                f32 scaleY = readFloat(input);
                f32 width = readFloat(input) * self.scale;
                f32 height = readFloat(input) * self.scale;
                var region = cast(spRegionAttachment*, spAttachmentLoader_createAttachment(self.attachmentLoader, skin, type, name, path, sequence));
                region.path = path;
                region.rotation = rotation;
                region.x = x;
                region.y = y;
                region.scaleX = scaleX;
                region.scaleY = scaleY;
                region.width = width;
                region.height = height;
                spColor_setFromColor(&region.color, &color);
                region.sequence = sequence;
                if sequence == null {
                    spRegionAttachment_updateRegion(region);
                }
                spAttachmentLoader_configureAttachment(self.attachmentLoader, &region.super);
                return &region.super;
            }
        }
        case SP_ATTACHMENT_BOUNDING_BOX: {
            {
                var box = cast(spBoundingBoxAttachment*, spAttachmentLoader_createAttachment(self.attachmentLoader, skin, type, name, null, null));
                if box == null {
                    return null;
                }
                SkeletonBinary___readVertices(input, &box.super.vertices, &box.super.verticesCount, &box.super.bones, &box.super.bonesCount, cast(i32, (flags & 16) != 0), self.scale);
                box.super.worldVerticesLength = box.super.verticesCount;
                if nonessential != 0 {
                    readColor(input, &box.color.r, &box.color.g, &box.color.b, &box.color.a);
                }
                spAttachmentLoader_configureAttachment(self.attachmentLoader, &box.super.super);
                return &box.super.super;
            }
        }
        case SP_ATTACHMENT_MESH: {
            {
                f32* uvs = null;
                i32 uvsCount = 0;
                u16* triangles = null;
                i32 trianglesCount = 0;
                f32* vertices = null;
                i32 verticesCount = 0;
                i32* bones = null;
                i32 bonesCount = 0;
                i32 hullLength = 0;
                f32 width = 0.0f;
                f32 height = 0.0f;
                u16* edges = null;
                i32 edgesCount = 0;
                u8* path = (flags & 16) != 0 ? readStringRef(input, skeletonData) : name;
                path = string_copy(path);
                noinit spColor color;
                spColor_setFromFloats(&color, 1.0f, 1.0f, 1.0f, 1.0f);
                if (flags & 32) != 0 {
                    readColor(input, &color.r, &color.g, &color.b, &color.a);
                }
                spSequence* sequence = (flags & 64) != 0 ? SkeletonBinary__readSequence(input) : null;
                hullLength = readVarint(input, 1);
                i32 verticesLength = SkeletonBinary___readVertices(input, &vertices, &verticesCount, &bones, &bonesCount, cast(i32, (flags & 128) != 0), self.scale);
                uvsCount = verticesLength;
                uvs = _readFloatArray(input, uvsCount, 1.0f);
                trianglesCount = (verticesLength - hullLength - 2) * 3;
                triangles = _readShortArray(input, trianglesCount);
                if nonessential != 0 {
                    edgesCount = readVarint(input, 1);
                    edges = _readShortArray(input, edgesCount);
                    width = readFloat(input);
                    height = readFloat(input);
                }
                spAttachment* attachment = spAttachmentLoader_createAttachment(self.attachmentLoader, skin, type, name, path, sequence);
                if attachment == null {
                    return null;
                }
                var mesh = cast(spMeshAttachment*, attachment);
                mesh.path = path;
                spColor_setFromColor(&mesh.color, &color);
                mesh.regionUVs = uvs;
                mesh.triangles = triangles;
                mesh.trianglesCount = trianglesCount;
                mesh.super.vertices = vertices;
                mesh.super.verticesCount = verticesCount;
                mesh.super.bones = bones;
                mesh.super.bonesCount = bonesCount;
                mesh.super.worldVerticesLength = verticesLength;
                mesh.hullLength = hullLength;
                mesh.edges = edges;
                mesh.edgesCount = edgesCount;
                mesh.width = width;
                mesh.height = height;
                mesh.sequence = sequence;
                if sequence == null {
                    spMeshAttachment_updateRegion(mesh);
                }
                spAttachmentLoader_configureAttachment(self.attachmentLoader, attachment);
                return attachment;
            }
        }
        case SP_ATTACHMENT_LINKED_MESH: {
            {
                u8* path = (flags & 16) != 0 ? readStringRef(input, skeletonData) : name;
                path = string_copy(path);
                noinit spColor color;
                spColor_setFromFloats(&color, 1.0f, 1.0f, 1.0f, 1.0f);
                if (flags & 32) != 0 {
                    readColor(input, &color.r, &color.g, &color.b, &color.a);
                }
                spSequence* sequence = (flags & 64) != 0 ? SkeletonBinary__readSequence(input) : null;
                i32 inheritTimelines = (flags & 128) != 0;
                i32 skinIndex = readVarint(input, 1);
                u8* parent = readStringRef(input, skeletonData);
                f32 width = 0.0f;
                f32 height = 0.0f;
                if nonessential != 0 {
                    width = readFloat(input) * self.scale;
                    height = readFloat(input) * self.scale;
                }
                spAttachment* attachment = spAttachmentLoader_createAttachment(self.attachmentLoader, skin, type, name, path, sequence);
                spMeshAttachment* mesh = null;
                if attachment == null {
                    return null;
                }
                mesh = cast(spMeshAttachment*, attachment);
                mesh.path = path;
                if mesh.path != null {
                    u8* tmp = null;
                    tmp = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(mesh.path) + 1), "extension.h", 97));
                    strcpy(tmp, mesh.path);
                    mesh.path = tmp;
                }
                spColor_setFromColor(&mesh.color, &color);
                mesh.sequence = sequence;
                mesh.width = width;
                mesh.height = height;
                _spSkeletonBinary_addLinkedMesh(self, mesh, skinIndex, slotIndex, parent, inheritTimelines);
                return attachment;
            }
        }
        case SP_ATTACHMENT_PATH: {
            {
                spAttachment* attachment = spAttachmentLoader_createAttachment(self.attachmentLoader, skin, type, name, null, null);
                spPathAttachment* path = null;
                if attachment == null {
                    return null;
                }
                path = cast(spPathAttachment*, attachment);
                path.closed = (flags & 16) != 0;
                path.constantSpeed = (flags & 32) != 0;
                i32 verticesLength = SkeletonBinary___readVertices(input, &path.super.vertices, &path.super.verticesCount, &path.super.bones, &path.super.bonesCount, cast(i32, (flags & 64) != 0), self.scale);
                path.super.worldVerticesLength = verticesLength;
                path.lengthsLength = verticesLength / 6;
                path.lengths = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * path.lengthsLength), "extension.h", 97));
                for i32 i = 0; i < path.lengthsLength; ++i {
                    path.lengths[i] = readFloat(input) * self.scale;
                }
                if nonessential != 0 {
                    readColor(input, &path.color.r, &path.color.g, &path.color.b, &path.color.a);
                }
                spAttachmentLoader_configureAttachment(self.attachmentLoader, attachment);
                return attachment;
            }
        }
        case SP_ATTACHMENT_POINT: {
            {
                spAttachment* attachment = spAttachmentLoader_createAttachment(self.attachmentLoader, skin, type, name, null, null);
                spPointAttachment* point = null;
                if attachment == null {
                    return null;
                }
                point = cast(spPointAttachment*, attachment);
                point.rotation = readFloat(input);
                point.x = readFloat(input) * self.scale;
                point.y = readFloat(input) * self.scale;
                if nonessential != 0 {
                    readColor(input, &point.color.r, &point.color.g, &point.color.b, &point.color.a);
                }
                spAttachmentLoader_configureAttachment(self.attachmentLoader, attachment);
                return attachment;
            }
        }
        case SP_ATTACHMENT_CLIPPING: {
            {
                i32 endSlotIndex = readVarint(input, 1);
                spAttachment* attachment = spAttachmentLoader_createAttachment(self.attachmentLoader, skin, type, name, null, null);
                spClippingAttachment* clip = null;
                if attachment == null {
                    return null;
                }
                clip = cast(spClippingAttachment*, attachment);
                i32 verticesLength = SkeletonBinary___readVertices(input, &clip.super.vertices, &clip.super.verticesCount, &clip.super.bones, &clip.super.bonesCount, cast(i32, (flags & 16) != 0), self.scale);
                clip.super.worldVerticesLength = verticesLength;
                if nonessential != 0 {
                    readColor(input, &clip.color.r, &clip.color.g, &clip.color.b, &clip.color.a);
                }
                clip.endSlot = skeletonData.slots[endSlotIndex];
                spAttachmentLoader_configureAttachment(self.attachmentLoader, attachment);
                return attachment;
            }
        }
    }
    return null;
}

spSkin* spSkeletonBinary_readSkin(spSkeletonBinary* self, _dataInput* input, i32 defaultSkin, spSkeletonData* skeletonData, i32 nonessential) {
    spSkin* skin;
    i32 i;
    i32 n;
    i32 ii;
    i32 nn;
    i32 slotCount;
    if defaultSkin != 0 {
        slotCount = readVarint(input, 1);
        if slotCount == 0 {
            return null;
        }
        skin = spSkin_create("default");
    } else {
        u8* name = readString(input);
        skin = spSkin_create(name);
        _spFree(cast(void*, name));
        if nonessential != 0 {
            readColor(input, &skin.color.r, &skin.color.g, &skin.color.b, &skin.color.a);
        }
        {
            i = 0;
            for n = readVarint(input, 1); i < n; i++ {
                spBoneDataArray_add(skin.bones, skeletonData.bones[readVarint(input, 1)]);
            }
        }
        {
            i = 0;
            for n = readVarint(input, 1); i < n; i++ {
                spIkConstraintDataArray_add(skin.ikConstraints, skeletonData.ikConstraints[readVarint(input, 1)]);
            }
        }
        {
            i = 0;
            for n = readVarint(input, 1); i < n; i++ {
                spTransformConstraintDataArray_add(skin.transformConstraints, skeletonData.transformConstraints[readVarint(input, 1)]);
            }
        }
        {
            i = 0;
            for n = readVarint(input, 1); i < n; i++ {
                spPathConstraintDataArray_add(skin.pathConstraints, skeletonData.pathConstraints[readVarint(input, 1)]);
            }
        }
        {
            i = 0;
            for n = readVarint(input, 1); i < n; i++ {
                spPhysicsConstraintDataArray_add(skin.physicsConstraints, skeletonData.physicsConstraints[readVarint(input, 1)]);
            }
        }
        slotCount = readVarint(input, 1);
    }
    for i = 0; i < slotCount; ++i {
        i32 slotIndex = readVarint(input, 1);
        {
            ii = 0;
            for nn = readVarint(input, 1); ii < nn; ++ii {
                u8* name = readStringRef(input, skeletonData);
                spAttachment* attachment = spSkeletonBinary_readAttachment(self, input, skin, slotIndex, name, skeletonData, nonessential);
                if attachment == null {
                    return null;
                }
                spSkin_setAttachment(skin, slotIndex, name, attachment);
            }
        }
    }
    return skin;
}

spSkeletonData* spSkeletonBinary_readSkeletonDataFile(spSkeletonBinary* self, u8* path) {
    i32 length;
    spSkeletonData* skeletonData;
    u8* binary = _spUtil_readFile(path, &length);
    if length == 0 || !binary {
        _spSkeletonBinary_setError(self, "Unable to read skeleton file: ", path);
        return null;
    }
    skeletonData = spSkeletonBinary_readSkeletonData(self, cast(u8*, binary), length);
    _spFree(cast(void*, binary));
    return skeletonData;
}

spSkeletonData* spSkeletonBinary_readSkeletonData(spSkeletonBinary* self, u8* binary, i32 length) {
    i32 i;
    i32 n;
    i32 ii;
    i32 nonessential;
    noinit u8[32] buffer;
    i32 lowHash;
    i32 highHash;
    spSkeletonData* skeletonData;
    var internal = cast(_spSkeletonBinary*, self);
    var input = cast(_dataInput*, _spCalloc(1, cast(u64, sizeof(_dataInput)), "extension.h", 100));
    input.cursor = binary;
    input.end = binary + length;
    _spFree(cast(void*, self.error));
    self.error = null;
    internal.linkedMeshCount = 0;
    skeletonData = spSkeletonData_create();
    lowHash = readInt(input);
    highHash = readInt(input);
    snprintf(buffer, 32, "%x%x", highHash, lowHash);
    buffer[31] = 0;
    skeletonData.hash = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(buffer) + 1), "extension.h", 97));
    strcpy(skeletonData.hash, buffer);
    skeletonData.version = readString(input);
    if strlen(skeletonData.version) == 0 {
        _spFree(cast(void*, skeletonData.version));
        skeletonData.version = null;
    } else {
        if SkeletonBinary__string_starts_with(skeletonData.version, "4.2") == 0 {
            _spFree(cast(void*, input));
            noinit u8[255] errorMsg;
            snprintf(errorMsg, 255, "Skeleton version %s does not match runtime version %s", skeletonData.version, "4.2");
            spSkeletonData_dispose(skeletonData);
            _spSkeletonBinary_setError(self, errorMsg, null);
            return null;
        }
    }
    skeletonData.x = readFloat(input);
    skeletonData.y = readFloat(input);
    skeletonData.width = readFloat(input);
    skeletonData.height = readFloat(input);
    skeletonData.referenceScale = readFloat(input);
    nonessential = readBoolean(input);
    if nonessential != 0 {
        skeletonData.fps = readFloat(input);
        skeletonData.imagesPath = readString(input);
        if strlen(skeletonData.imagesPath) == 0 {
            _spFree(cast(void*, skeletonData.imagesPath));
            skeletonData.imagesPath = null;
        }
        skeletonData.audioPath = readString(input);
        if strlen(skeletonData.audioPath) == 0 {
            _spFree(cast(void*, skeletonData.audioPath));
            skeletonData.audioPath = null;
        }
    }
    n = readVarint(input, 1);
    skeletonData.stringsCount = n;
    skeletonData.strings = cast(u8**, _spMalloc(cast(u64, sizeof(u8*) * skeletonData.stringsCount), "extension.h", 97));
    for i = 0; i < n; i++ {
        skeletonData.strings[i] = readString(input);
    }
    skeletonData.bonesCount = readVarint(input, 1);
    skeletonData.bones = cast(spBoneData**, _spMalloc(cast(u64, sizeof(spBoneData*) * skeletonData.bonesCount), "extension.h", 97));
    for i = 0; i < skeletonData.bonesCount; ++i {
        u8* name = readString(input);
        spBoneData* parent = i == 0 ? null : skeletonData.bones[readVarint(input, 1)];
        spBoneData* data = spBoneData_create(i, name, parent);
        _spFree(cast(void*, name));
        data.rotation = readFloat(input);
        data.x = readFloat(input) * self.scale;
        data.y = readFloat(input) * self.scale;
        data.scaleX = readFloat(input);
        data.scaleY = readFloat(input);
        data.shearX = readFloat(input);
        data.shearY = readFloat(input);
        data.length = readFloat(input) * self.scale;
        data.inherit = cast(spInherit, readVarint(input, 1));
        data.skinRequired = readBoolean(input);
        if nonessential != 0 {
            readColor(input, &data.color.r, &data.color.g, &data.color.b, &data.color.a);
            data.icon = readString(input);
            data.visible = readBoolean(input);
        }
        skeletonData.bones[i] = data;
    }
    skeletonData.slotsCount = readVarint(input, 1);
    skeletonData.slots = cast(spSlotData**, _spMalloc(cast(u64, sizeof(spSlotData*) * skeletonData.slotsCount), "extension.h", 97));
    for i = 0; i < skeletonData.slotsCount; ++i {
        u8* slotName = readString(input);
        spBoneData* boneData = skeletonData.bones[readVarint(input, 1)];
        spSlotData* slotData = spSlotData_create(i, slotName, boneData);
        _spFree(cast(void*, slotName));
        readColor(input, &slotData.color.r, &slotData.color.g, &slotData.color.b, &slotData.color.a);
        var a = cast(i32, readByte(input));
        var r = cast(i32, readByte(input));
        var g = cast(i32, readByte(input));
        var b = cast(i32, readByte(input));
        if (r == 0xff && g == 0xff && b == 0xff && a == 0xff) == 0 {
            slotData.darkColor = spColor_create();
            spColor_setFromFloats(slotData.darkColor, cast(f32, r) / 255.0f, cast(f32, g) / 255.0f, cast(f32, b) / 255.0f, 1.0f);
        }
        u8* attachmentName = readStringRef(input, skeletonData);
        if attachmentName != null {
            slotData.attachmentName = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(attachmentName) + 1), "extension.h", 97));
            strcpy(slotData.attachmentName, attachmentName);
        } else {
            slotData.attachmentName = null;
        }
        slotData.blendMode = cast(spBlendMode, readVarint(input, 1));
        if nonessential != 0 {
            slotData.visible = readBoolean(input);
        }
        skeletonData.slots[i] = slotData;
    }
    skeletonData.ikConstraintsCount = readVarint(input, 1);
    skeletonData.ikConstraints = cast(spIkConstraintData**, _spMalloc(cast(u64, sizeof(spIkConstraintData*) * skeletonData.ikConstraintsCount), "extension.h", 97));
    for i = 0; i < skeletonData.ikConstraintsCount; ++i {
        u8* name = readString(input);
        spIkConstraintData* data = spIkConstraintData_create(name);
        _spFree(cast(void*, name));
        data.order = readVarint(input, 1);
        data.bonesCount = readVarint(input, 1);
        data.bones = cast(spBoneData**, _spMalloc(cast(u64, sizeof(spBoneData*) * data.bonesCount), "extension.h", 97));
        for ii = 0; ii < data.bonesCount; ++ii {
            data.bones[ii] = skeletonData.bones[readVarint(input, 1)];
        }
        data.target = skeletonData.bones[readVarint(input, 1)];
        var flags = cast(i32, readByte(input));
        data.skinRequired = (flags & 1) != 0;
        data.bendDirection = (flags & 2) != 0 ? 1 : -1;
        data.compress = (flags & 4) != 0;
        data.stretch = (flags & 8) != 0;
        data.uniform = (flags & 16) != 0;
        if (flags & 32) != 0 {
            data.mix = (flags & 64) != 0 ? readFloat(input) : 1.0f;
        }
        if (flags & 128) != 0 {
            data.softness = readFloat(input) * self.scale;
        }
        skeletonData.ikConstraints[i] = data;
    }
    skeletonData.transformConstraintsCount = readVarint(input, 1);
    skeletonData.transformConstraints = cast(spTransformConstraintData**, _spMalloc(cast(u64, sizeof(spTransformConstraintData*) * skeletonData.transformConstraintsCount), "extension.h", 97));
    for i = 0; i < skeletonData.transformConstraintsCount; ++i {
        u8* name = readString(input);
        spTransformConstraintData* data = spTransformConstraintData_create(name);
        _spFree(cast(void*, name));
        data.order = readVarint(input, 1);
        data.bonesCount = readVarint(input, 1);
        data.bones = cast(spBoneData**, _spMalloc(cast(u64, sizeof(spBoneData*) * data.bonesCount), "extension.h", 97));
        for ii = 0; ii < data.bonesCount; ++ii {
            data.bones[ii] = skeletonData.bones[readVarint(input, 1)];
        }
        data.target = skeletonData.bones[readVarint(input, 1)];
        var flags = cast(i32, readByte(input));
        data.skinRequired = (flags & 1) != 0;
        data.local = (flags & 2) != 0;
        data.relative = (flags & 4) != 0;
        if (flags & 8) != 0 {
            data.offsetRotation = readFloat(input);
        }
        if (flags & 16) != 0 {
            data.offsetX = readFloat(input) * self.scale;
        }
        if (flags & 32) != 0 {
            data.offsetY = readFloat(input) * self.scale;
        }
        if (flags & 64) != 0 {
            data.offsetScaleX = readFloat(input);
        }
        if (flags & 128) != 0 {
            data.offsetScaleY = readFloat(input);
        }
        flags = cast(i32, readByte(input));
        if (flags & 1) != 0 {
            data.offsetShearY = readFloat(input);
        }
        if (flags & 2) != 0 {
            data.mixRotate = readFloat(input);
        }
        if (flags & 4) != 0 {
            data.mixX = readFloat(input);
        }
        if (flags & 8) != 0 {
            data.mixY = readFloat(input);
        }
        if (flags & 16) != 0 {
            data.mixScaleX = readFloat(input);
        }
        if (flags & 32) != 0 {
            data.mixScaleY = readFloat(input);
        }
        if (flags & 64) != 0 {
            data.mixShearY = readFloat(input);
        }
        skeletonData.transformConstraints[i] = data;
    }
    skeletonData.pathConstraintsCount = readVarint(input, 1);
    skeletonData.pathConstraints = cast(spPathConstraintData**, _spMalloc(cast(u64, sizeof(spPathConstraintData*) * skeletonData.pathConstraintsCount), "extension.h", 97));
    for i = 0; i < skeletonData.pathConstraintsCount; ++i {
        u8* name = readString(input);
        spPathConstraintData* data = spPathConstraintData_create(name);
        _spFree(cast(void*, name));
        data.order = readVarint(input, 1);
        data.skinRequired = readBoolean(input);
        data.bonesCount = readVarint(input, 1);
        data.bones = cast(spBoneData**, _spMalloc(cast(u64, sizeof(spBoneData*) * data.bonesCount), "extension.h", 97));
        for ii = 0; ii < data.bonesCount; ++ii {
            data.bones[ii] = skeletonData.bones[readVarint(input, 1)];
        }
        data.target = skeletonData.slots[readVarint(input, 1)];
        var flags = cast(i32, readByte(input));
        data.positionMode = cast(spPositionMode, flags & 1);
        data.spacingMode = cast(spSpacingMode, flags >> 1 & 3);
        data.rotateMode = cast(spRotateMode, flags >> 3 & 3);
        if (flags & 128) != 0 {
            data.offsetRotation = readFloat(input);
        }
        data.position = readFloat(input);
        if data.positionMode == SP_POSITION_MODE_FIXED {
            data.position *= self.scale;
        }
        data.spacing = readFloat(input);
        if data.spacingMode == SP_SPACING_MODE_LENGTH || data.spacingMode == SP_SPACING_MODE_FIXED {
            data.spacing *= self.scale;
        }
        data.mixRotate = readFloat(input);
        data.mixX = readFloat(input);
        data.mixY = readFloat(input);
        skeletonData.pathConstraints[i] = data;
    }
    skeletonData.physicsConstraintsCount = readVarint(input, 1);
    skeletonData.physicsConstraints = cast(spPhysicsConstraintData**, _spMalloc(cast(u64, sizeof(spPhysicsConstraintData*) * skeletonData.physicsConstraintsCount), "extension.h", 97));
    for i = 0; i < skeletonData.physicsConstraintsCount; i++ {
        u8* name = readString(input);
        spPhysicsConstraintData* data = spPhysicsConstraintData_create(name);
        _spFree(cast(void*, name));
        data.order = readVarint(input, 1);
        data.bone = skeletonData.bones[readVarint(input, 1)];
        var flags = cast(i32, readByte(input));
        data.skinRequired = (flags & 1) != 0;
        if (flags & 2) != 0 {
            data.x = readFloat(input);
        }
        if (flags & 4) != 0 {
            data.y = readFloat(input);
        }
        if (flags & 8) != 0 {
            data.rotate = readFloat(input);
        }
        if (flags & 16) != 0 {
            data.scaleX = readFloat(input);
        }
        if (flags & 32) != 0 {
            data.shearX = readFloat(input);
        }
        data.limit = ((flags & 64) != 0 ? readFloat(input) : 5000.0f) * self.scale;
        data.step = 1.0f / cast(f32, readByte(input));
        data.inertia = readFloat(input);
        data.strength = readFloat(input);
        data.damping = readFloat(input);
        data.massInverse = (flags & 128) != 0 ? readFloat(input) : 1.0f;
        data.wind = readFloat(input);
        data.gravity = readFloat(input);
        flags = cast(i32, readByte(input));
        if (flags & 1) != 0 {
            data.inertiaGlobal = -1;
        }
        if (flags & 2) != 0 {
            data.strengthGlobal = -1;
        }
        if (flags & 4) != 0 {
            data.dampingGlobal = -1;
        }
        if (flags & 8) != 0 {
            data.massGlobal = -1;
        }
        if (flags & 16) != 0 {
            data.windGlobal = -1;
        }
        if (flags & 32) != 0 {
            data.gravityGlobal = -1;
        }
        if (flags & 64) != 0 {
            data.mixGlobal = -1;
        }
        data.mix = (flags & 128) != 0 ? readFloat(input) : 1.0f;
        skeletonData.physicsConstraints[i] = data;
    }
    skeletonData.defaultSkin = spSkeletonBinary_readSkin(self, input, -1, skeletonData, nonessential);
    if self.attachmentLoader.error1 != null {
        _spFree(cast(void*, input));
        spSkin_dispose(skeletonData.defaultSkin);
        spSkeletonData_dispose(skeletonData);
        _spSkeletonBinary_setError(self, self.attachmentLoader.error1, self.attachmentLoader.error2);
        return null;
    }
    skeletonData.skinsCount = readVarint(input, 1);
    if skeletonData.defaultSkin != null {
        ++skeletonData.skinsCount;
    }
    skeletonData.skins = cast(spSkin**, _spMalloc(cast(u64, sizeof(spSkin*) * skeletonData.skinsCount), "extension.h", 97));
    if skeletonData.defaultSkin != null {
        skeletonData.skins[0] = skeletonData.defaultSkin;
    }
    for i = skeletonData.defaultSkin != null ? 1 : 0; i < skeletonData.skinsCount; ++i {
        spSkin* skin = spSkeletonBinary_readSkin(self, input, 0, skeletonData, nonessential);
        if self.attachmentLoader.error1 != null {
            _spFree(cast(void*, input));
            skeletonData.skinsCount = i + 1;
            spSkeletonData_dispose(skeletonData);
            _spSkeletonBinary_setError(self, self.attachmentLoader.error1, self.attachmentLoader.error2);
            return null;
        }
        skeletonData.skins[i] = skin;
    }
    for i = 0; i < internal.linkedMeshCount; ++i {
        _spLinkedMeshBinary* linkedMesh = internal.linkedMeshes + i;
        spSkin* skin = skeletonData.skins[linkedMesh.skinIndex];
        if skin == null {
            _spFree(cast(void*, input));
            spSkeletonData_dispose(skeletonData);
            _spSkeletonBinary_setError(self, "Skin not found", "");
            return null;
        }
        spAttachment* parent = spSkin_getAttachment(skin, linkedMesh.slotIndex, linkedMesh.parent);
        if parent == null {
            _spFree(cast(void*, input));
            spSkeletonData_dispose(skeletonData);
            _spSkeletonBinary_setError(self, "Parent mesh not found: ", linkedMesh.parent);
            return null;
        }
        linkedMesh.mesh.super.timelineAttachment = linkedMesh.inheritTimeline != 0 ? parent : &linkedMesh.mesh.super.super;
        spMeshAttachment_setParentMesh(linkedMesh.mesh, cast(spMeshAttachment*, parent));
        if linkedMesh.mesh.region != null {
            spMeshAttachment_updateRegion(linkedMesh.mesh);
        }
        spAttachmentLoader_configureAttachment(self.attachmentLoader, &linkedMesh.mesh.super.super);
    }
    skeletonData.eventsCount = readVarint(input, 1);
    skeletonData.events = cast(spEventData**, _spMalloc(cast(u64, sizeof(spEventData*) * skeletonData.eventsCount), "extension.h", 97));
    for i = 0; i < skeletonData.eventsCount; ++i {
        u8* name = readString(input);
        spEventData* eventData = spEventData_create(name);
        _spFree(cast(void*, name));
        eventData.intValue = readVarint(input, 0);
        eventData.floatValue = readFloat(input);
        eventData.stringValue = readString(input);
        eventData.audioPath = readString(input);
        if eventData.audioPath != null {
            eventData.volume = readFloat(input);
            eventData.balance = readFloat(input);
        }
        skeletonData.events[i] = eventData;
    }
    skeletonData.animationsCount = readVarint(input, 1);
    skeletonData.animations = cast(spAnimation**, _spMalloc(cast(u64, sizeof(spAnimation*) * skeletonData.animationsCount), "extension.h", 97));
    for i = 0; i < skeletonData.animationsCount; ++i {
        u8* name = readString(input);
        spAnimation* animation = _spSkeletonBinary_readAnimation(self, name, input, skeletonData);
        _spFree(cast(void*, name));
        if animation == null {
            _spFree(cast(void*, input));
            skeletonData.animationsCount = i + 1;
            spSkeletonData_dispose(skeletonData);
            _spSkeletonBinary_setError(self, "Animation corrupted: ", name);
            return null;
        }
        skeletonData.animations[i] = animation;
    }
    _spFree(cast(void*, input));
    return skeletonData;
}

spPolygon* spPolygon_create(i32 capacity) {
    var self = cast(spPolygon*, _spCalloc(1, cast(u64, sizeof(spPolygon)), "extension.h", 92));
    self.capacity = capacity;
    self.vertices = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * capacity), "extension.h", 88));
    return self;
}

void spPolygon_dispose(spPolygon* self) {
    _spFree(cast(void*, self.vertices));
    _spFree(cast(void*, self));
}

i32 spPolygon_containsPoint(spPolygon* self, f32 x, f32 y) {
    i32 prevIndex = self.count - 2;
    i32 inside = 0;
    i32 i;
    for i = 0; i < self.count; i += 2 {
        f32 vertexY = self.vertices[i + 1];
        f32 prevY = self.vertices[prevIndex + 1];
        if vertexY < y && prevY >= y || prevY < y && vertexY >= y {
            f32 vertexX = self.vertices[i];
            if vertexX + (y - vertexY) / (prevY - vertexY) * (self.vertices[prevIndex] - vertexX) < x {
                inside = !inside;
            }
        }
        prevIndex = i;
    }
    return inside;
}

i32 spPolygon_intersectsSegment(spPolygon* self, f32 x1, f32 y1, f32 x2, f32 y2) {
    f32 width12 = x1 - x2;
    f32 height12 = y1 - y2;
    f32 det1 = x1 * y2 - y1 * x2;
    f32 x3 = self.vertices[self.count - 2];
    f32 y3 = self.vertices[self.count - 1];
    i32 i;
    for i = 0; i < self.count; i += 2 {
        f32 x4 = self.vertices[i];
        f32 y4 = self.vertices[i + 1];
        f32 det2 = x3 * y4 - y3 * x4;
        f32 width34 = x3 - x4;
        f32 height34 = y3 - y4;
        f32 det3 = width12 * height34 - height12 * width34;
        f32 x = (det1 * width34 - width12 * det2) / det3;
        if (x >= x3 && x <= x4 || x >= x4 && x <= x3) && (x >= x1 && x <= x2 || x >= x2 && x <= x1) {
            f32 y = (det1 * height34 - height12 * det2) / det3;
            if (y >= y3 && y <= y4 || y >= y4 && y <= y3) && (y >= y1 && y <= y2 || y >= y2 && y <= y1) {
                return 1;
            }
        }
        x3 = x4;
        y3 = y4;
    }
    return 0;
}

spSkeletonBounds* spSkeletonBounds_create() {
    return &cast(_spSkeletonBounds*, _spCalloc(1, cast(u64, sizeof(_spSkeletonBounds)), "extension.h", 92)).super;
}

void spSkeletonBounds_dispose(spSkeletonBounds* self) {
    i32 i;
    for i = 0; i < cast(_spSkeletonBounds*, self).capacity; ++i {
        if self.polygons[i] != null {
            spPolygon_dispose(self.polygons[i]);
        }
    }
    _spFree(cast(void*, self.polygons));
    _spFree(cast(void*, self.boundingBoxes));
    _spFree(cast(void*, self));
}

void spSkeletonBounds_update(spSkeletonBounds* self, spSkeleton* skeleton, i32 updateAabb) {
    i32 i;
    var internal = cast(_spSkeletonBounds*, self);
    if internal.capacity < skeleton.slotsCount {
        spPolygon** newPolygons;
        _spFree(cast(void*, self.boundingBoxes));
        self.boundingBoxes = cast(spBoundingBoxAttachment**, _spMalloc(cast(u64, sizeof(spBoundingBoxAttachment*) * skeleton.slotsCount), "extension.h", 88));
        newPolygons = cast(spPolygon**, _spCalloc(cast(u64, skeleton.slotsCount), cast(u64, sizeof(spPolygon*)), "extension.h", 92));
        memcpy(newPolygons, self.polygons, cast(u64, sizeof(spPolygon*) * internal.capacity));
        _spFree(cast(void*, self.polygons));
        self.polygons = newPolygons;
        internal.capacity = skeleton.slotsCount;
    }
    self.minX = cast(f32, INT_MAX);
    self.minY = cast(f32, INT_MAX);
    self.maxX = cast(f32, INT_MIN);
    self.maxY = cast(f32, INT_MIN);
    self.count = 0;
    for i = 0; i < skeleton.slotsCount; ++i {
        spPolygon* polygon;
        spBoundingBoxAttachment* boundingBox;
        spAttachment* attachment;
        spSlot* slot = skeleton.slots[i];
        if slot.bone.active == 0 {
            continue;
        }
        attachment = slot.attachment;
        if !attachment || attachment.type != SP_ATTACHMENT_BOUNDING_BOX {
            continue;
        }
        boundingBox = cast(spBoundingBoxAttachment*, attachment);
        self.boundingBoxes[self.count] = boundingBox;
        polygon = self.polygons[self.count];
        if !polygon || polygon.capacity < boundingBox.super.worldVerticesLength {
            if polygon != null {
                spPolygon_dispose(polygon);
            }
            polygon = spPolygon_create(boundingBox.super.worldVerticesLength);
            self.polygons[self.count] = polygon;
        }
        polygon.count = boundingBox.super.worldVerticesLength;
        spVertexAttachment_computeWorldVertices(&boundingBox.super, slot, 0, polygon.count, polygon.vertices, 0, 2);
        if updateAabb != 0 {
            i32 ii = 0;
            for ; ii < polygon.count; ii += 2 {
                f32 x = polygon.vertices[ii];
                f32 y = polygon.vertices[ii + 1];
                if x < self.minX {
                    self.minX = x;
                }
                if y < self.minY {
                    self.minY = y;
                }
                if x > self.maxX {
                    self.maxX = x;
                }
                if y > self.maxY {
                    self.maxY = y;
                }
            }
        }
        self.count++;
    }
}

i32 spSkeletonBounds_aabbContainsPoint(spSkeletonBounds* self, f32 x, f32 y) {
    return x >= self.minX && x <= self.maxX && y >= self.minY && y <= self.maxY;
}

i32 spSkeletonBounds_aabbIntersectsSegment(spSkeletonBounds* self, f32 x1, f32 y1, f32 x2, f32 y2) {
    f32 m;
    f32 x;
    f32 y;
    if x1 <= self.minX && x2 <= self.minX || y1 <= self.minY && y2 <= self.minY || x1 >= self.maxX && x2 >= self.maxX || y1 >= self.maxY && y2 >= self.maxY {
        return 0;
    }
    m = (y2 - y1) / (x2 - x1);
    y = m * (self.minX - x1) + y1;
    if y > self.minY && y < self.maxY {
        return 1;
    }
    y = m * (self.maxX - x1) + y1;
    if y > self.minY && y < self.maxY {
        return 1;
    }
    x = (self.minY - y1) / m + x1;
    if x > self.minX && x < self.maxX {
        return 1;
    }
    x = (self.maxY - y1) / m + x1;
    if x > self.minX && x < self.maxX {
        return 1;
    }
    return 0;
}

i32 spSkeletonBounds_aabbIntersectsSkeleton(spSkeletonBounds* self, spSkeletonBounds* bounds) {
    return self.minX < bounds.maxX && self.maxX > bounds.minX && self.minY < bounds.maxY && self.maxY > bounds.minY;
}

spBoundingBoxAttachment* spSkeletonBounds_containsPoint(spSkeletonBounds* self, f32 x, f32 y) {
    i32 i;
    for i = 0; i < self.count; ++i {
        if spPolygon_containsPoint(self.polygons[i], x, y) != 0 {
            return self.boundingBoxes[i];
        }
    }
    return null;
}

spBoundingBoxAttachment* spSkeletonBounds_intersectsSegment(spSkeletonBounds* self, f32 x1, f32 y1, f32 x2, f32 y2) {
    i32 i;
    for i = 0; i < self.count; ++i {
        if spPolygon_intersectsSegment(self.polygons[i], x1, y1, x2, y2) != 0 {
            return self.boundingBoxes[i];
        }
    }
    return null;
}

spPolygon* spSkeletonBounds_getPolygon(spSkeletonBounds* self, spBoundingBoxAttachment* boundingBox) {
    i32 i;
    for i = 0; i < self.count; ++i {
        if self.boundingBoxes[i] == boundingBox {
            return self.polygons[i];
        }
    }
    return null;
}

spSkeletonClipping* spSkeletonClipping_create() {
    var clipping = cast(spSkeletonClipping*, _spCalloc(1, cast(u64, sizeof(spSkeletonClipping)), "extension.h", 87));
    clipping.triangulator = spTriangulator_create();
    clipping.clippingPolygon = spFloatArray_create(128);
    clipping.clipOutput = spFloatArray_create(128);
    clipping.clippedVertices = spFloatArray_create(128);
    clipping.clippedUVs = spFloatArray_create(128);
    clipping.clippedTriangles = spUnsignedShortArray_create(128);
    clipping.scratch = spFloatArray_create(128);
    return clipping;
}

void spSkeletonClipping_dispose(spSkeletonClipping* self) {
    spTriangulator_dispose(self.triangulator);
    spFloatArray_dispose(self.clippingPolygon);
    spFloatArray_dispose(self.clipOutput);
    spFloatArray_dispose(self.clippedVertices);
    spFloatArray_dispose(self.clippedUVs);
    spUnsignedShortArray_dispose(self.clippedTriangles);
    spFloatArray_dispose(self.scratch);
    _spFree(cast(void*, self));
}

private {
void _makeClockwise(spFloatArray* polygon) {
    i32 i;
    i32 n;
    i32 lastX;
    f32* vertices = polygon.items;
    i32 verticeslength = polygon.size;
    f32 area = vertices[verticeslength - 2] * vertices[1] - vertices[0] * vertices[verticeslength - 1];
    f32 p1x;
    f32 p1y;
    f32 p2x;
    f32 p2y;
    {
        i = 0;
        for n = verticeslength - 3; i < n; i += 2 {
            p1x = vertices[i];
            p1y = vertices[i + 1];
            p2x = vertices[i + 2];
            p2y = vertices[i + 3];
            area += p1x * p2y - p2x * p1y;
        }
    }
    if area < 0.0f {
        return;
    }
    {
        i = 0;
        lastX = verticeslength - 2;
        for n = verticeslength >> 1; i < n; i += 2 {
            f32 x = vertices[i];
            f32 y = vertices[i + 1];
            i32 other = lastX - i;
            vertices[i] = vertices[other];
            vertices[i + 1] = vertices[other + 1];
            vertices[other] = x;
            vertices[other + 1] = y;
        }
    }
}
}

i32 spSkeletonClipping_clipStart(spSkeletonClipping* self, spSlot* slot, spClippingAttachment* clip) {
    i32 i;
    i32 n;
    f32* vertices;
    if self.clipAttachment != null {
        return 0;
    }
    self.clipAttachment = clip;
    n = clip.super.worldVerticesLength;
    vertices = spFloatArray_setSize(self.clippingPolygon, n).items;
    spVertexAttachment_computeWorldVertices(&clip.super, slot, 0, n, vertices, 0, 2);
    _makeClockwise(self.clippingPolygon);
    self.clippingPolygons = spTriangulator_decompose(self.triangulator, self.clippingPolygon, spTriangulator_triangulate(self.triangulator, self.clippingPolygon));
    {
        i = 0;
        for n = self.clippingPolygons.size; i < n; i++ {
            spFloatArray* polygon = self.clippingPolygons.items[i];
            _makeClockwise(polygon);
            spFloatArray_add(polygon, polygon.items[0]);
            spFloatArray_add(polygon, polygon.items[1]);
        }
    }
    return self.clippingPolygons.size;
}

void spSkeletonClipping_clipEnd(spSkeletonClipping* self, spSlot* slot) {
    if self.clipAttachment != null && self.clipAttachment.endSlot == slot.data {
        spSkeletonClipping_clipEnd2(self);
    }
}

void spSkeletonClipping_clipEnd2(spSkeletonClipping* self) {
    if self.clipAttachment == null {
        return;
    }
    self.clipAttachment = null;
    self.clippingPolygons = null;
    spFloatArray_clear(self.clippedVertices);
    spFloatArray_clear(self.clippedUVs);
    spUnsignedShortArray_clear(self.clippedTriangles);
    spFloatArray_clear(self.clippingPolygon);
}

i32 spSkeletonClipping_isClipping(spSkeletonClipping* self) {
    return self.clipAttachment != null;
}

i32 _clip(spSkeletonClipping* self, f32 x1, f32 y1, f32 x2, f32 y2, f32 x3, f32 y3, spFloatArray* clippingArea, spFloatArray* output) {
    spFloatArray* originalOutput = output;
    i32 clipped = 0;
    f32* clippingVertices;
    i32 clippingVerticesLast;
    spFloatArray* input = null;
    if clippingArea.size % 4 >= 2 {
        input = output;
        output = self.scratch;
    } else {
        input = self.scratch;
    }
    spFloatArray_clear(input);
    spFloatArray_add(input, x1);
    spFloatArray_add(input, y1);
    spFloatArray_add(input, x2);
    spFloatArray_add(input, y2);
    spFloatArray_add(input, x3);
    spFloatArray_add(input, y3);
    spFloatArray_add(input, x1);
    spFloatArray_add(input, y1);
    spFloatArray_clear(output);
    clippingVerticesLast = clippingArea.size - 4;
    clippingVertices = clippingArea.items;
    for i32 i = 0; true; i += 2 {
        spFloatArray* temp;
        f32 edgeX = clippingVertices[i];
        f32 edgeY = clippingVertices[i + 1];
        f32 ex = edgeX - clippingVertices[i + 2];
        f32 ey = edgeY - clippingVertices[i + 3];
        i32 outputStart = output.size;
        f32* inputVertices = input.items;
        {
            i32 ii = 0;
            i32 nn = input.size - 2;
            while ii < nn {
                f32 inputX = inputVertices[ii];
                f32 inputY = inputVertices[ii + 1];
                ii += 2;
                f32 inputX2 = inputVertices[ii];
                f32 inputY2 = inputVertices[ii + 1];
                var s2 = cast(f32, ey * (edgeX - inputX2) > ex * (edgeY - inputY2));
                f32 s1 = ey * (edgeX - inputX) - ex * (edgeY - inputY);
                if s1 > 0.0f {
                    if s2 != 0.0f {
                        spFloatArray_add(output, inputX2);
                        spFloatArray_add(output, inputY2);
                        continue;
                    }
                    f32 ix = inputX2 - inputX;
                    f32 iy = inputY2 - inputY;
                    f32 t = s1 / (ix * ey - iy * ex);
                    if t >= 0.0f && t <= 1.0f {
                        spFloatArray_add(output, inputX + ix * t);
                        spFloatArray_add(output, inputY + iy * t);
                    } else {
                        spFloatArray_add(output, inputX2);
                        spFloatArray_add(output, inputY2);
                    }
                } else if s2 != 0.0f {
                    f32 ix = inputX2 - inputX;
                    f32 iy = inputY2 - inputY;
                    f32 t = s1 / (ix * ey - iy * ex);
                    if t >= 0.0f && t <= 1.0f {
                        spFloatArray_add(output, inputX + ix * t);
                        spFloatArray_add(output, inputY + iy * t);
                        spFloatArray_add(output, inputX2);
                        spFloatArray_add(output, inputY2);
                    } else {
                        spFloatArray_add(output, inputX2);
                        spFloatArray_add(output, inputY2);
                        continue;
                    }
                }
                clipped = -1;
            }
        }
        if outputStart == output.size {
            spFloatArray_clear(originalOutput);
            return 1;
        }
        spFloatArray_add(output, output.items[0]);
        spFloatArray_add(output, output.items[1]);
        if i == clippingVerticesLast {
            break;
        }
        temp = output;
        output = input;
        spFloatArray_clear(output);
        input = temp;
    }
    if originalOutput != output {
        spFloatArray_clear(originalOutput);
        spFloatArray_addAllValues(originalOutput, output.items, 0, output.size - 2);
    } else {
        spFloatArray_setSize(originalOutput, originalOutput.size - 2);
    }
    return clipped;
}

void spSkeletonClipping_clipTriangles(spSkeletonClipping* self, f32* vertices, i32 verticesLength, u16* triangles, i32 trianglesLength, f32* uvs, i32 stride) {
    i32 i;
    spFloatArray* clipOutput = self.clipOutput;
    spFloatArray* clippedVertices = self.clippedVertices;
    spFloatArray* clippedUVs = self.clippedUVs;
    spUnsignedShortArray* clippedTriangles = self.clippedTriangles;
    spFloatArray** polygons = self.clippingPolygons.items;
    i32 polygonsCount = self.clippingPolygons.size;
    i16 index = 0;
    spFloatArray_clear(clippedVertices);
    spFloatArray_clear(clippedUVs);
    spUnsignedShortArray_clear(clippedTriangles);
    i = 0;
    bool __retry_continue_outer = false;
    while true {
        __retry_continue_outer = false;
        {
            for ; i < trianglesLength; i += 3 {
                i32 p;
                i32 vertexOffset = triangles[i] * stride;
                f32 x2;
                f32 y2;
                f32 u2;
                f32 v2;
                f32 x3;
                f32 y3;
                f32 u3;
                f32 v3;
                f32 x1 = vertices[vertexOffset];
                f32 y1 = vertices[vertexOffset + 1];
                f32 u1 = uvs[vertexOffset];
                f32 v1 = uvs[vertexOffset + 1];
                vertexOffset = triangles[i + 1] * stride;
                x2 = vertices[vertexOffset];
                y2 = vertices[vertexOffset + 1];
                u2 = uvs[vertexOffset];
                v2 = uvs[vertexOffset + 1];
                vertexOffset = triangles[i + 2] * stride;
                x3 = vertices[vertexOffset];
                y3 = vertices[vertexOffset + 1];
                u3 = uvs[vertexOffset];
                v3 = uvs[vertexOffset + 1];
                {
                    for p = 0; p < polygonsCount; p++ {
                        i32 s = clippedVertices.size;
                        if _clip(self, x1, y1, x2, y2, x3, y3, polygons[p], clipOutput) != 0 {
                            i32 ii;
                            f32 d0;
                            f32 d1;
                            f32 d2;
                            f32 d4;
                            f32 d;
                            u16* clippedTrianglesItems;
                            i32 clipOutputCount;
                            f32* clipOutputItems;
                            f32* clippedVerticesItems;
                            f32* clippedUVsItems;
                            i32 clipOutputLength = clipOutput.size;
                            if clipOutputLength == 0 {
                                continue;
                            }
                            d0 = y2 - y3;
                            d1 = x3 - x2;
                            d2 = x1 - x3;
                            d4 = y3 - y1;
                            d = 1.0f / (d0 * d2 + d1 * (y1 - y3));
                            clipOutputCount = clipOutputLength >> 1;
                            clipOutputItems = clipOutput.items;
                            clippedVerticesItems = spFloatArray_setSize(clippedVertices, s + (clipOutputCount << 1)).items;
                            clippedUVsItems = spFloatArray_setSize(clippedUVs, s + (clipOutputCount << 1)).items;
                            for ii = 0; ii < clipOutputLength; ii += 2 {
                                f32 c0;
                                f32 c1;
                                f32 a;
                                f32 b;
                                f32 c;
                                f32 x = clipOutputItems[ii];
                                f32 y = clipOutputItems[ii + 1];
                                clippedVerticesItems[s] = x;
                                clippedVerticesItems[s + 1] = y;
                                c0 = x - x3;
                                c1 = y - y3;
                                a = (d0 * c0 + d1 * c1) * d;
                                b = (d4 * c0 + d2 * c1) * d;
                                c = 1.0f - a - b;
                                clippedUVsItems[s] = u1 * a + u2 * b + u3 * c;
                                clippedUVsItems[s + 1] = v1 * a + v2 * b + v3 * c;
                                s += 2;
                            }
                            s = clippedTriangles.size;
                            clippedTrianglesItems = spUnsignedShortArray_setSize(clippedTriangles, s + 3 * (clipOutputCount - 2)).items;
                            clipOutputCount--;
                            for ii = 1; ii < clipOutputCount; ii++ {
                                clippedTrianglesItems[s] = cast(u16, index);
                                clippedTrianglesItems[s + 1] = cast(u16, index + ii);
                                clippedTrianglesItems[s + 2] = cast(u16, index + ii + 1);
                                s += 3;
                            }
                            index += cast(i16, clipOutputCount + 1);
                        } else {
                            u16* clippedTrianglesItems;
                            f32* clippedVerticesItems = spFloatArray_setSize(clippedVertices, s + (3 << 1)).items;
                            f32* clippedUVsItems = spFloatArray_setSize(clippedUVs, s + (3 << 1)).items;
                            clippedVerticesItems[s] = x1;
                            clippedVerticesItems[s + 1] = y1;
                            clippedVerticesItems[s + 2] = x2;
                            clippedVerticesItems[s + 3] = y2;
                            clippedVerticesItems[s + 4] = x3;
                            clippedVerticesItems[s + 5] = y3;
                            clippedUVsItems[s] = u1;
                            clippedUVsItems[s + 1] = v1;
                            clippedUVsItems[s + 2] = u2;
                            clippedUVsItems[s + 3] = v2;
                            clippedUVsItems[s + 4] = u3;
                            clippedUVsItems[s + 5] = v3;
                            s = clippedTriangles.size;
                            clippedTrianglesItems = spUnsignedShortArray_setSize(clippedTriangles, s + 3).items;
                            clippedTrianglesItems[s] = cast(u16, index);
                            clippedTrianglesItems[s + 1] = cast(u16, index + 1);
                            clippedTrianglesItems[s + 2] = cast(u16, index + 2);
                            index += 3;
                            i += 3;
                            {
                                __retry_continue_outer = true;
                                break;
                            }
                        }
                    }
                    if __retry_continue_outer {
                        break;
                    }
                }
            }
            if __retry_continue_outer {
                continue;
            }
        }
        ignore verticesLength;
        break;
    }
}

spSkeletonData* spSkeletonData_create() {
    return cast(spSkeletonData*, _spCalloc(1, cast(u64, sizeof(spSkeletonData)), "extension.h", 98));
}

void spSkeletonData_dispose(spSkeletonData* self) {
    i32 i;
    for i = 0; i < self.stringsCount; ++i {
        _spFree(cast(void*, self.strings[i]));
    }
    _spFree(cast(void*, self.strings));
    for i = 0; i < self.bonesCount; ++i {
        spBoneData_dispose(self.bones[i]);
    }
    _spFree(cast(void*, self.bones));
    for i = 0; i < self.slotsCount; ++i {
        spSlotData_dispose(self.slots[i]);
    }
    _spFree(cast(void*, self.slots));
    for i = 0; i < self.skinsCount; ++i {
        spSkin_dispose(self.skins[i]);
    }
    _spFree(cast(void*, self.skins));
    for i = 0; i < self.eventsCount; ++i {
        spEventData_dispose(self.events[i]);
    }
    _spFree(cast(void*, self.events));
    for i = 0; i < self.animationsCount; ++i {
        spAnimation_dispose(self.animations[i]);
    }
    _spFree(cast(void*, self.animations));
    for i = 0; i < self.ikConstraintsCount; ++i {
        spIkConstraintData_dispose(self.ikConstraints[i]);
    }
    _spFree(cast(void*, self.ikConstraints));
    for i = 0; i < self.transformConstraintsCount; ++i {
        spTransformConstraintData_dispose(self.transformConstraints[i]);
    }
    _spFree(cast(void*, self.transformConstraints));
    for i = 0; i < self.pathConstraintsCount; i++ {
        spPathConstraintData_dispose(self.pathConstraints[i]);
    }
    _spFree(cast(void*, self.pathConstraints));
    for i = 0; i < self.physicsConstraintsCount; i++ {
        spPhysicsConstraintData_dispose(self.physicsConstraints[i]);
    }
    _spFree(cast(void*, self.physicsConstraints));
    _spFree(cast(void*, self.hash));
    _spFree(cast(void*, self.version));
    _spFree(cast(void*, self.imagesPath));
    _spFree(cast(void*, self.audioPath));
    _spFree(cast(void*, self));
}

spBoneData* spSkeletonData_findBone(spSkeletonData* self, u8* boneName) {
    i32 i;
    for i = 0; i < self.bonesCount; ++i {
        if strcmp(self.bones[i].name, boneName) == 0 {
            return self.bones[i];
        }
    }
    return null;
}

spSlotData* spSkeletonData_findSlot(spSkeletonData* self, u8* slotName) {
    i32 i;
    for i = 0; i < self.slotsCount; ++i {
        if strcmp(self.slots[i].name, slotName) == 0 {
            return self.slots[i];
        }
    }
    return null;
}

spSkin* spSkeletonData_findSkin(spSkeletonData* self, u8* skinName) {
    i32 i;
    for i = 0; i < self.skinsCount; ++i {
        if strcmp(self.skins[i].name, skinName) == 0 {
            return self.skins[i];
        }
    }
    return null;
}

spEventData* spSkeletonData_findEvent(spSkeletonData* self, u8* eventName) {
    i32 i;
    for i = 0; i < self.eventsCount; ++i {
        if strcmp(self.events[i].name, eventName) == 0 {
            return self.events[i];
        }
    }
    return null;
}

spAnimation* spSkeletonData_findAnimation(spSkeletonData* self, u8* animationName) {
    i32 i;
    for i = 0; i < self.animationsCount; ++i {
        if strcmp(self.animations[i].name, animationName) == 0 {
            return self.animations[i];
        }
    }
    return null;
}

spIkConstraintData* spSkeletonData_findIkConstraint(spSkeletonData* self, u8* constraintName) {
    i32 i;
    for i = 0; i < self.ikConstraintsCount; ++i {
        if strcmp(self.ikConstraints[i].name, constraintName) == 0 {
            return self.ikConstraints[i];
        }
    }
    return null;
}

spTransformConstraintData* spSkeletonData_findTransformConstraint(spSkeletonData* self, u8* constraintName) {
    i32 i;
    for i = 0; i < self.transformConstraintsCount; ++i {
        if strcmp(self.transformConstraints[i].name, constraintName) == 0 {
            return self.transformConstraints[i];
        }
    }
    return null;
}

spPathConstraintData* spSkeletonData_findPathConstraint(spSkeletonData* self, u8* constraintName) {
    i32 i;
    for i = 0; i < self.pathConstraintsCount; ++i {
        if strcmp(self.pathConstraints[i].name, constraintName) == 0 {
            return self.pathConstraints[i];
        }
    }
    return null;
}

spPhysicsConstraintData* spSkeletonData_findPhysicsConstraint(spSkeletonData* self, u8* constraintName) {
    i32 i;
    for i = 0; i < self.physicsConstraintsCount; ++i {
        if strcmp(self.physicsConstraints[i].name, constraintName) == 0 {
            return self.physicsConstraints[i];
        }
    }
    return null;
}

spSkeletonJson* spSkeletonJson_createWithLoader(spAttachmentLoader* attachmentLoader) {
    spSkeletonJson* self = &cast(_spSkeletonJson*, _spCalloc(1, cast(u64, sizeof(_spSkeletonJson)), "extension.h", 99)).super;
    self.scale = 1.0f;
    self.attachmentLoader = attachmentLoader;
    return self;
}

spSkeletonJson* spSkeletonJson_create(spAtlas* atlas) {
    spAtlasAttachmentLoader* attachmentLoader = spAtlasAttachmentLoader_create(atlas);
    spSkeletonJson* self = spSkeletonJson_createWithLoader(&attachmentLoader.super);
    cast(_spSkeletonJson*, self).ownsLoader = 1;
    return self;
}

void spSkeletonJson_dispose(spSkeletonJson* self) {
    var internal = cast(_spSkeletonJson*, self);
    if internal.ownsLoader != 0 {
        spAttachmentLoader_dispose(self.attachmentLoader);
    }
    _spFree(cast(void*, internal.linkedMeshes));
    _spFree(cast(void*, self.error));
    _spFree(cast(void*, self));
}

void _spSkeletonJson_setError(spSkeletonJson* self, Json* root, u8* value1, u8* value2) {
    noinit u8[256] message;
    i32 length;
    _spFree(cast(void*, self.error));
    strcpy(message, value1);
    length = cast(i32, strlen(value1));
    if value2 != null {
        strncat(message + length, value2, cast(u64, 255 - length));
    }
    self.error = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(message) + 1), "extension.h", 96));
    strcpy(self.error, message);
    if root != null {
        Json_dispose(root);
    }
}

private {
f32 toColor(u8* value, i32 index) {
    noinit u8[3] digits;
    u8* error;
    i32 color;
    if cast(u64, index) >= strlen(value) / 2 {
        return cast(f32, -1);
    }
    value += index * 2;
    digits[0] = *value;
    digits[1] = *(value + 1);
    digits[2] = 0;
    color = cast(i32, strtoul(digits, &error, 16));
    if *error != 0 {
        return cast(f32, -1);
    }
    return cast(f32, color) / cast(f32, 255);
}

void toColor2(spColor* color, u8* value, i32 hasAlpha) {
    color.r = toColor(value, 0);
    color.g = toColor(value, 1);
    color.b = toColor(value, 2);
    if hasAlpha != 0 {
        color.a = toColor(value, 3);
    } else {
        color.a = 1.0f;
    }
}

void SkeletonJson__setBezier(spCurveTimeline* timeline, i32 frame, i32 value, i32 bezier, f32 time1, f32 value1, f32 cx1, f32 cy1, f32 cx2, f32 cy2, f32 time2, f32 value2) {
    spTimeline_setBezier(&timeline.super, bezier, frame, cast(f32, value), time1, value1, cx1, cy1, cx2, cy2, time2, value2);
}

i32 readCurve(Json* curve, spCurveTimeline* timeline, i32 bezier, i32 frame, i32 value, f32 time1, f32 time2, f32 value1, f32 value2, f32 scale) {
    f32 cx1;
    f32 cy1;
    f32 cx2;
    f32 cy2;
    if curve.type == 4 && strcmp(curve.valueString, "stepped") == 0 {
        spCurveTimeline_setStepped(timeline, frame);
        return bezier;
    }
    curve = Json_getItemAtIndex(curve, value << 2);
    cx1 = curve.valueFloat;
    curve = curve.next;
    cy1 = curve.valueFloat * scale;
    curve = curve.next;
    cx2 = curve.valueFloat;
    curve = curve.next;
    cy2 = curve.valueFloat * scale;
    SkeletonJson__setBezier(timeline, frame, value, bezier, time1, value1, cx1, cy1, cx2, cy2, time2, value2);
    return bezier + 1;
}

spTimeline* SkeletonJson__readTimeline(Json* keyMap, spCurveTimeline1* timeline, f32 defaultValue, f32 scale) {
    f32 time = Json_getFloat(keyMap, "time", 0.0f);
    f32 value = Json_getFloat(keyMap, "value", defaultValue) * scale;
    i32 frame;
    i32 bezier = 0;
    for frame = 0; true; ++frame {
        Json* nextMap;
        Json* curve;
        f32 time2;
        f32 value2;
        spCurveTimeline1_setFrame(timeline, frame, time, value);
        nextMap = keyMap.next;
        if nextMap == null {
            break;
        }
        time2 = Json_getFloat(nextMap, "time", 0.0f);
        value2 = Json_getFloat(nextMap, "value", defaultValue) * scale;
        curve = Json_getItem(keyMap, "curve");
        if curve != null {
            bezier = readCurve(curve, timeline, bezier, frame, 0, time, time2, value, value2, scale);
        }
        time = time2;
        value = value2;
        keyMap = nextMap;
    }
    return &timeline.super;
}

spTimeline* SkeletonJson__readTimeline2(Json* keyMap, spCurveTimeline2* timeline, u8* name1, u8* name2, f32 defaultValue, f32 scale) {
    f32 time = Json_getFloat(keyMap, "time", 0.0f);
    f32 value1 = Json_getFloat(keyMap, name1, defaultValue) * scale;
    f32 value2 = Json_getFloat(keyMap, name2, defaultValue) * scale;
    i32 frame;
    i32 bezier = 0;
    for frame = 0; true; ++frame {
        Json* nextMap;
        Json* curve;
        f32 time2;
        f32 nvalue1;
        f32 nvalue2;
        spCurveTimeline2_setFrame(timeline, frame, time, value1, value2);
        nextMap = keyMap.next;
        if nextMap == null {
            break;
        }
        time2 = Json_getFloat(nextMap, "time", 0.0f);
        nvalue1 = Json_getFloat(nextMap, name1, defaultValue) * scale;
        nvalue2 = Json_getFloat(nextMap, name2, defaultValue) * scale;
        curve = Json_getItem(keyMap, "curve");
        if curve != null {
            bezier = readCurve(curve, timeline, bezier, frame, 0, time, time2, value1, nvalue1, scale);
            bezier = readCurve(curve, timeline, bezier, frame, 1, time, time2, value2, nvalue2, scale);
        }
        time = time2;
        value1 = nvalue1;
        value2 = nvalue2;
        keyMap = nextMap;
    }
    return &timeline.super;
}

spSequence* SkeletonJson__readSequence(Json* item) {
    spSequence* sequence;
    if item == null {
        return null;
    }
    sequence = spSequence_create(Json_getInt(item, "count", 0));
    sequence.start = Json_getInt(item, "start", 1);
    sequence.digits = Json_getInt(item, "digits", 0);
    sequence.setupIndex = Json_getInt(item, "setupIndex", 0);
    return sequence;
}

void _spSkeletonJson_addLinkedMesh(spSkeletonJson* self, spMeshAttachment* mesh, u8* skin, i32 slotIndex, u8* parent, i32 inheritDeform) {
    _spLinkedMesh* linkedMesh;
    var internal = cast(_spSkeletonJson*, self);
    if internal.linkedMeshCount == internal.linkedMeshCapacity {
        _spLinkedMesh* linkedMeshes;
        internal.linkedMeshCapacity *= 2;
        if internal.linkedMeshCapacity < 8 {
            internal.linkedMeshCapacity = 8;
        }
        linkedMeshes = cast(_spLinkedMesh*, _spMalloc(cast(u64, sizeof(_spLinkedMesh) * internal.linkedMeshCapacity), "extension.h", 96));
        memcpy(linkedMeshes, internal.linkedMeshes, cast(u64, sizeof(_spLinkedMesh) * internal.linkedMeshCount));
        _spFree(cast(void*, internal.linkedMeshes));
        internal.linkedMeshes = linkedMeshes;
    }
    linkedMesh = internal.linkedMeshes + internal.linkedMeshCount++;
    linkedMesh.mesh = mesh;
    linkedMesh.skin = skin;
    linkedMesh.slotIndex = slotIndex;
    linkedMesh.parent = parent;
    linkedMesh.inheritTimeline = inheritDeform;
}

void cleanUpTimelines(spTimelineArray* timelines) {
    i32 i;
    i32 n;
    {
        i = 0;
        for n = timelines.size; i < n; ++i {
            spTimeline_dispose(timelines.items[i]);
        }
    }
    spTimelineArray_dispose(timelines);
}

i32 findSlotIndex(spSkeletonJson* json, spSkeletonData* skeletonData, u8* slotName, spTimelineArray* timelines) {
    spSlotData* slot = spSkeletonData_findSlot(skeletonData, slotName);
    if slot != null {
        return slot.index;
    }
    cleanUpTimelines(timelines);
    _spSkeletonJson_setError(json, null, "Slot not found: ", slotName);
    return -1;
}
}

i32 findIkConstraintIndex(spSkeletonJson* json, spSkeletonData* skeletonData, spIkConstraintData* constraint, spTimelineArray* timelines) {
    if constraint != null {
        i32 i;
        for i = 0; i < skeletonData.ikConstraintsCount; ++i {
            if skeletonData.ikConstraints[i] == constraint {
                return i;
            }
        }
    }
    cleanUpTimelines(timelines);
    _spSkeletonJson_setError(json, null, "IK constraint not found: ", constraint.name);
    return -1;
}

i32 findTransformConstraintIndex(spSkeletonJson* json, spSkeletonData* skeletonData, spTransformConstraintData* constraint, spTimelineArray* timelines) {
    if constraint != null {
        i32 i;
        for i = 0; i < skeletonData.transformConstraintsCount; ++i {
            if skeletonData.transformConstraints[i] == constraint {
                return i;
            }
        }
    }
    cleanUpTimelines(timelines);
    _spSkeletonJson_setError(json, null, "Transform constraint not found: ", constraint.name);
    return -1;
}

i32 findPathConstraintIndex(spSkeletonJson* json, spSkeletonData* skeletonData, spPathConstraintData* constraint, spTimelineArray* timelines) {
    if constraint != null {
        i32 i;
        for i = 0; i < skeletonData.pathConstraintsCount; ++i {
            if skeletonData.pathConstraints[i] == constraint {
                return i;
            }
        }
    }
    cleanUpTimelines(timelines);
    _spSkeletonJson_setError(json, null, "Path constraint not found: ", constraint.name);
    return -1;
}

i32 findPhysicsConstraintIndex(spSkeletonJson* json, spSkeletonData* skeletonData, spPhysicsConstraintData* constraint, spTimelineArray* timelines) {
    if constraint != null {
        i32 i;
        for i = 0; i < skeletonData.physicsConstraintsCount; ++i {
            if skeletonData.physicsConstraints[i] == constraint {
                return i;
            }
        }
    }
    cleanUpTimelines(timelines);
    _spSkeletonJson_setError(json, null, "Physics constraint not found: ", constraint.name);
    return -1;
}

private {
spAnimation* _spSkeletonJson_readAnimation(spSkeletonJson* self, Json* root, spSkeletonData* skeletonData) {
    spTimelineArray* timelines = spTimelineArray_create(8);
    f32 scale = self.scale;
    f32 duration;
    Json* bones = Json_getItem(root, "bones");
    Json* slots = Json_getItem(root, "slots");
    Json* ik = Json_getItem(root, "ik");
    Json* transform = Json_getItem(root, "transform");
    Json* paths = Json_getItem(root, "path");
    Json* physics = Json_getItem(root, "physics");
    Json* attachmentsJson = Json_getItem(root, "attachments");
    Json* drawOrderJson = Json_getItem(root, "drawOrder");
    Json* events = Json_getItem(root, "events");
    Json* boneMap;
    Json* slotMap;
    Json* keyMap;
    Json* nextMap;
    Json* curve;
    Json* timelineMap;
    Json* attachmentsMap;
    Json* constraintMap;
    i32 frame;
    i32 bezier;
    i32 i;
    i32 n;
    noinit spColor color;
    noinit spColor color2;
    noinit spColor newColor;
    noinit spColor newColor2;
    for slotMap = slots != null ? slots.child : null; slotMap != null; slotMap = slotMap.next {
        i32 slotIndex = findSlotIndex(self, skeletonData, slotMap.name, timelines);
        if slotIndex == -1 {
            return null;
        }
        for timelineMap = slotMap.child; timelineMap != null; timelineMap = timelineMap.next {
            i32 frames = timelineMap.size;
            if strcmp(timelineMap.name, "attachment") == 0 {
                spAttachmentTimeline* timeline = spAttachmentTimeline_create(frames, slotIndex);
                {
                    keyMap = timelineMap.child;
                    for frame = 0; keyMap != null; keyMap = keyMap.next {
                        spAttachmentTimeline_setFrame(timeline, frame, Json_getFloat(keyMap, "time", 0.0f), Json_getItem(keyMap, "name") != null ? Json_getItem(keyMap, "name").valueString : null);
                        ++frame;
                    }
                }
                spTimelineArray_add(timelines, &timeline.super);
            } else if strcmp(timelineMap.name, "rgba") == 0 {
                f32 time;
                spRGBATimeline* timeline = spRGBATimeline_create(frames, frames << 2, slotIndex);
                keyMap = timelineMap.child;
                time = Json_getFloat(keyMap, "time", 0.0f);
                toColor2(&color, Json_getString(keyMap, "color", null), 1);
                {
                    frame = 0;
                    for bezier = 0; true; ++frame {
                        f32 time2;
                        spRGBATimeline_setFrame(timeline, frame, time, color.r, color.g, color.b, color.a);
                        nextMap = keyMap.next;
                        if nextMap == null {
                            break;
                        }
                        time2 = Json_getFloat(nextMap, "time", 0.0f);
                        toColor2(&newColor, Json_getString(nextMap, "color", null), 1);
                        curve = Json_getItem(keyMap, "curve");
                        if curve != null {
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 0, time, time2, color.r, newColor.r, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 1, time, time2, color.g, newColor.g, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 2, time, time2, color.b, newColor.b, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 3, time, time2, color.a, newColor.a, 1.0f);
                        }
                        time = time2;
                        color = newColor;
                        keyMap = nextMap;
                    }
                }
                spTimelineArray_add(timelines, &timeline.super.super);
            } else if strcmp(timelineMap.name, "rgb") == 0 {
                f32 time;
                spRGBTimeline* timeline = spRGBTimeline_create(frames, frames * 3, slotIndex);
                keyMap = timelineMap.child;
                time = Json_getFloat(keyMap, "time", 0.0f);
                toColor2(&color, Json_getString(keyMap, "color", null), 1);
                {
                    frame = 0;
                    for bezier = 0; true; ++frame {
                        f32 time2;
                        spRGBTimeline_setFrame(timeline, frame, time, color.r, color.g, color.b);
                        nextMap = keyMap.next;
                        if nextMap == null {
                            break;
                        }
                        time2 = Json_getFloat(nextMap, "time", 0.0f);
                        toColor2(&newColor, Json_getString(nextMap, "color", null), 1);
                        curve = Json_getItem(keyMap, "curve");
                        if curve != null {
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 0, time, time2, color.r, newColor.r, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 1, time, time2, color.g, newColor.g, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 2, time, time2, color.b, newColor.b, 1.0f);
                        }
                        time = time2;
                        color = newColor;
                        keyMap = nextMap;
                    }
                }
                spTimelineArray_add(timelines, &timeline.super.super);
            } else if strcmp(timelineMap.name, "alpha") == 0 {
                spTimelineArray_add(timelines, SkeletonJson__readTimeline(timelineMap.child, &spAlphaTimeline_create(frames, frames, slotIndex).super, 0.0f, 1.0f));
            } else if strcmp(timelineMap.name, "rgba2") == 0 {
                f32 time;
                spRGBA2Timeline* timeline = spRGBA2Timeline_create(frames, frames * 7, slotIndex);
                keyMap = timelineMap.child;
                time = Json_getFloat(keyMap, "time", 0.0f);
                toColor2(&color, Json_getString(keyMap, "light", null), 1);
                toColor2(&color2, Json_getString(keyMap, "dark", null), 0);
                {
                    frame = 0;
                    for bezier = 0; true; ++frame {
                        f32 time2;
                        spRGBA2Timeline_setFrame(timeline, frame, time, color.r, color.g, color.b, color.a, color2.g, color2.g, color2.b);
                        nextMap = keyMap.next;
                        if nextMap == null {
                            break;
                        }
                        time2 = Json_getFloat(nextMap, "time", 0.0f);
                        toColor2(&newColor, Json_getString(nextMap, "light", null), 1);
                        toColor2(&newColor2, Json_getString(nextMap, "dark", null), 0);
                        curve = Json_getItem(keyMap, "curve");
                        if curve != null {
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 0, time, time2, color.r, newColor.r, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 1, time, time2, color.g, newColor.g, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 2, time, time2, color.b, newColor.b, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 3, time, time2, color.a, newColor.a, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 4, time, time2, color2.r, newColor2.r, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 5, time, time2, color2.g, newColor2.g, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 6, time, time2, color2.b, newColor2.b, 1.0f);
                        }
                        time = time2;
                        color = newColor;
                        color2 = newColor2;
                        keyMap = nextMap;
                    }
                }
                spTimelineArray_add(timelines, &timeline.super.super);
            } else if strcmp(timelineMap.name, "rgb2") == 0 {
                f32 time;
                spRGBA2Timeline* timeline = spRGBA2Timeline_create(frames, frames * 6, slotIndex);
                keyMap = timelineMap.child;
                time = Json_getFloat(keyMap, "time", 0.0f);
                toColor2(&color, Json_getString(keyMap, "light", null), 0);
                toColor2(&color2, Json_getString(keyMap, "dark", null), 0);
                {
                    frame = 0;
                    for bezier = 0; true; ++frame {
                        f32 time2;
                        spRGBA2Timeline_setFrame(timeline, frame, time, color.r, color.g, color.b, color.a, color2.r, color2.g, color2.b);
                        nextMap = keyMap.next;
                        if nextMap == null {
                            break;
                        }
                        time2 = Json_getFloat(nextMap, "time", 0.0f);
                        toColor2(&newColor, Json_getString(nextMap, "light", null), 0);
                        toColor2(&newColor2, Json_getString(nextMap, "dark", null), 0);
                        curve = Json_getItem(keyMap, "curve");
                        if curve != null {
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 0, time, time2, color.r, newColor.r, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 1, time, time2, color.g, newColor.g, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 2, time, time2, color.b, newColor.b, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 3, time, time2, color2.r, newColor2.r, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 4, time, time2, color2.g, newColor2.g, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 5, time, time2, color2.b, newColor2.b, 1.0f);
                        }
                        time = time2;
                        color = newColor;
                        color2 = newColor2;
                        keyMap = nextMap;
                    }
                }
                spTimelineArray_add(timelines, &timeline.super.super);
            } else {
                cleanUpTimelines(timelines);
                _spSkeletonJson_setError(self, null, "Invalid timeline type for a slot: ", timelineMap.name);
                return null;
            }
        }
    }
    for boneMap = bones != null ? bones.child : null; boneMap != null; boneMap = boneMap.next {
        i32 boneIndex = -1;
        for i = 0; i < skeletonData.bonesCount; ++i {
            if strcmp(skeletonData.bones[i].name, boneMap.name) == 0 {
                boneIndex = i;
                break;
            }
        }
        if boneIndex == -1 {
            cleanUpTimelines(timelines);
            _spSkeletonJson_setError(self, null, "Bone not found: ", boneMap.name);
            return null;
        }
        for timelineMap = boneMap.child; timelineMap != null; timelineMap = timelineMap.next {
            i32 frames = timelineMap.size;
            if frames == 0 {
                continue;
            }
            if strcmp(timelineMap.name, "rotate") == 0 {
                spTimelineArray_add(timelines, SkeletonJson__readTimeline(timelineMap.child, &spRotateTimeline_create(frames, frames, boneIndex).super, 0.0f, 1.0f));
            } else if strcmp(timelineMap.name, "translate") == 0 {
                spTranslateTimeline* timeline = spTranslateTimeline_create(frames, frames << 1, boneIndex);
                spTimelineArray_add(timelines, SkeletonJson__readTimeline2(timelineMap.child, &timeline.super, "x", "y", 0.0f, scale));
            } else if strcmp(timelineMap.name, "translatex") == 0 {
                spTranslateXTimeline* timeline = spTranslateXTimeline_create(frames, frames, boneIndex);
                spTimelineArray_add(timelines, SkeletonJson__readTimeline(timelineMap.child, &timeline.super, 0.0f, scale));
            } else if strcmp(timelineMap.name, "translatey") == 0 {
                spTranslateYTimeline* timeline = spTranslateYTimeline_create(frames, frames, boneIndex);
                spTimelineArray_add(timelines, SkeletonJson__readTimeline(timelineMap.child, &timeline.super, 0.0f, scale));
            } else if strcmp(timelineMap.name, "scale") == 0 {
                spScaleTimeline* timeline = spScaleTimeline_create(frames, frames << 1, boneIndex);
                spTimelineArray_add(timelines, SkeletonJson__readTimeline2(timelineMap.child, &timeline.super, "x", "y", 1.0f, 1.0f));
            } else if strcmp(timelineMap.name, "scalex") == 0 {
                spScaleXTimeline* timeline = spScaleXTimeline_create(frames, frames, boneIndex);
                spTimelineArray_add(timelines, SkeletonJson__readTimeline(timelineMap.child, &timeline.super, 1.0f, 1.0f));
            } else if strcmp(timelineMap.name, "scaley") == 0 {
                spScaleYTimeline* timeline = spScaleYTimeline_create(frames, frames, boneIndex);
                spTimelineArray_add(timelines, SkeletonJson__readTimeline(timelineMap.child, &timeline.super, 1.0f, 1.0f));
            } else if strcmp(timelineMap.name, "shear") == 0 {
                spShearTimeline* timeline = spShearTimeline_create(frames, frames << 1, boneIndex);
                spTimelineArray_add(timelines, SkeletonJson__readTimeline2(timelineMap.child, &timeline.super, "x", "y", 0.0f, 1.0f));
            } else if strcmp(timelineMap.name, "shearx") == 0 {
                spShearXTimeline* timeline = spShearXTimeline_create(frames, frames, boneIndex);
                spTimelineArray_add(timelines, SkeletonJson__readTimeline(timelineMap.child, &timeline.super, 0.0f, 1.0f));
            } else if strcmp(timelineMap.name, "sheary") == 0 {
                spShearYTimeline* timeline = spShearYTimeline_create(frames, frames, boneIndex);
                spTimelineArray_add(timelines, SkeletonJson__readTimeline(timelineMap.child, &timeline.super, 0.0f, 1.0f));
            } else if strcmp(timelineMap.name, "inherit") == 0 {
                spInheritTimeline* timeline = spInheritTimeline_create(frames, boneIndex);
                keyMap = timelineMap.child;
                for frame = 0; true; frame++ {
                    f32 time = Json_getFloat(keyMap, "time", 0.0f);
                    u8* value = Json_getString(keyMap, "inherit", "normal");
                    spInherit inherit = SP_INHERIT_NORMAL;
                    if strcmp(value, "normal") == 0 {
                        inherit = SP_INHERIT_NORMAL;
                    } else if strcmp(value, "onlyTranslation") == 0 {
                        inherit = SP_INHERIT_ONLYTRANSLATION;
                    } else if strcmp(value, "noRotationOrReflection") == 0 {
                        inherit = SP_INHERIT_NOROTATIONORREFLECTION;
                    } else if strcmp(value, "noScale") == 0 {
                        inherit = SP_INHERIT_NOSCALE;
                    } else if strcmp(value, "noScaleOrReflection") == 0 {
                        inherit = SP_INHERIT_NOSCALEORREFLECTION;
                    }
                    spInheritTimeline_setFrame(timeline, frame, time, inherit);
                    nextMap = keyMap.next;
                    if nextMap == null {
                        break;
                    }
                }
                spTimelineArray_add(timelines, &timeline.super);
            } else {
                cleanUpTimelines(timelines);
                _spSkeletonJson_setError(self, null, "Invalid timeline type for a bone: ", timelineMap.name);
                return null;
            }
        }
    }
    for constraintMap = ik != null ? ik.child : null; constraintMap != null; constraintMap = constraintMap.next {
        spIkConstraintData* constraint;
        spIkConstraintTimeline* timeline;
        i32 constraintIndex;
        f32 time;
        f32 mix;
        f32 softness;
        keyMap = constraintMap.child;
        if keyMap == null {
            continue;
        }
        constraint = spSkeletonData_findIkConstraint(skeletonData, constraintMap.name);
        constraintIndex = findIkConstraintIndex(self, skeletonData, constraint, timelines);
        if constraintIndex == -1 {
            return null;
        }
        timeline = spIkConstraintTimeline_create(constraintMap.size, constraintMap.size << 1, constraintIndex);
        time = Json_getFloat(keyMap, "time", 0.0f);
        mix = Json_getFloat(keyMap, "mix", 1.0f);
        softness = Json_getFloat(keyMap, "softness", 0.0f) * scale;
        {
            frame = 0;
            for bezier = 0; true; ++frame {
                f32 time2;
                f32 mix2;
                f32 softness2;
                i32 bendDirection = Json_getInt(keyMap, "bendPositive", 1) != 0 ? 1 : -1;
                spIkConstraintTimeline_setFrame(timeline, frame, time, mix, softness, bendDirection, Json_getInt(keyMap, "compress", 0) != 0 ? 1 : 0, Json_getInt(keyMap, "stretch", 0) != 0 ? 1 : 0);
                nextMap = keyMap.next;
                if nextMap == null {
                    break;
                }
                time2 = Json_getFloat(nextMap, "time", 0.0f);
                mix2 = Json_getFloat(nextMap, "mix", 1.0f);
                softness2 = Json_getFloat(nextMap, "softness", 0.0f) * scale;
                curve = Json_getItem(keyMap, "curve");
                if curve != null {
                    bezier = readCurve(curve, &timeline.super, bezier, frame, 0, time, time2, mix, mix2, 1.0f);
                    bezier = readCurve(curve, &timeline.super, bezier, frame, 1, time, time2, softness, softness2, scale);
                }
                time = time2;
                mix = mix2;
                softness = softness2;
                keyMap = nextMap;
            }
        }
        spTimelineArray_add(timelines, &timeline.super.super);
    }
    for constraintMap = transform != null ? transform.child : null; constraintMap != null; constraintMap = constraintMap.next {
        spTransformConstraintData* constraint;
        spTransformConstraintTimeline* timeline;
        i32 constraintIndex;
        f32 time;
        f32 mixRotate;
        f32 mixShearY;
        f32 mixX;
        f32 mixY;
        f32 mixScaleX;
        f32 mixScaleY;
        keyMap = constraintMap.child;
        if keyMap == null {
            continue;
        }
        constraint = spSkeletonData_findTransformConstraint(skeletonData, constraintMap.name);
        constraintIndex = findTransformConstraintIndex(self, skeletonData, constraint, timelines);
        if constraintIndex == -1 {
            return null;
        }
        timeline = spTransformConstraintTimeline_create(constraintMap.size, constraintMap.size * 6, constraintIndex);
        time = Json_getFloat(keyMap, "time", 0.0f);
        mixRotate = Json_getFloat(keyMap, "mixRotate", 1.0f);
        mixShearY = Json_getFloat(keyMap, "mixShearY", 1.0f);
        mixX = Json_getFloat(keyMap, "mixX", 1.0f);
        mixY = Json_getFloat(keyMap, "mixY", mixX);
        mixScaleX = Json_getFloat(keyMap, "mixScaleX", 1.0f);
        mixScaleY = Json_getFloat(keyMap, "mixScaleY", mixScaleX);
        {
            frame = 0;
            for bezier = 0; true; ++frame {
                f32 time2;
                f32 mixRotate2;
                f32 mixShearY2;
                f32 mixX2;
                f32 mixY2;
                f32 mixScaleX2;
                f32 mixScaleY2;
                spTransformConstraintTimeline_setFrame(timeline, frame, time, mixRotate, mixX, mixY, mixScaleX, mixScaleY, mixShearY);
                nextMap = keyMap.next;
                if nextMap == null {
                    break;
                }
                time2 = Json_getFloat(nextMap, "time", 0.0f);
                mixRotate2 = Json_getFloat(nextMap, "mixRotate", 1.0f);
                mixShearY2 = Json_getFloat(nextMap, "mixShearY", 1.0f);
                mixX2 = Json_getFloat(nextMap, "mixX", 1.0f);
                mixY2 = Json_getFloat(nextMap, "mixY", mixX2);
                mixScaleX2 = Json_getFloat(nextMap, "mixScaleX", 1.0f);
                mixScaleY2 = Json_getFloat(nextMap, "mixScaleY", mixScaleX2);
                curve = Json_getItem(keyMap, "curve");
                if curve != null {
                    bezier = readCurve(curve, &timeline.super, bezier, frame, 0, time, time2, mixRotate, mixRotate2, 1.0f);
                    bezier = readCurve(curve, &timeline.super, bezier, frame, 1, time, time2, mixX, mixX2, 1.0f);
                    bezier = readCurve(curve, &timeline.super, bezier, frame, 2, time, time2, mixY, mixY2, 1.0f);
                    bezier = readCurve(curve, &timeline.super, bezier, frame, 3, time, time2, mixScaleX, mixScaleX2, 1.0f);
                    bezier = readCurve(curve, &timeline.super, bezier, frame, 4, time, time2, mixScaleY, mixScaleY2, 1.0f);
                    bezier = readCurve(curve, &timeline.super, bezier, frame, 5, time, time2, mixShearY, mixShearY2, 1.0f);
                }
                time = time2;
                mixRotate = mixRotate2;
                mixX = mixX2;
                mixY = mixY2;
                mixScaleX = mixScaleX2;
                mixScaleY = mixScaleY2;
                mixScaleX = mixScaleX2;
                keyMap = nextMap;
            }
        }
        spTimelineArray_add(timelines, &timeline.super.super);
    }
    for constraintMap = paths != null ? paths.child : null; constraintMap != null; constraintMap = constraintMap.next {
        spPathConstraintData* constraint = spSkeletonData_findPathConstraint(skeletonData, constraintMap.name);
        i32 constraintIndex = findPathConstraintIndex(self, skeletonData, constraint, timelines);
        if constraintIndex == -1 {
            return null;
        }
        for timelineMap = constraintMap.child; timelineMap != null; timelineMap = timelineMap.next {
            u8* timelineName;
            i32 frames;
            keyMap = timelineMap.child;
            if keyMap == null {
                continue;
            }
            frames = timelineMap.size;
            timelineName = timelineMap.name;
            if strcmp(timelineName, "position") == 0 {
                spPathConstraintPositionTimeline* timeline = spPathConstraintPositionTimeline_create(frames, frames, constraintIndex);
                spTimelineArray_add(timelines, SkeletonJson__readTimeline(keyMap, &timeline.super, 0.0f, constraint.positionMode == SP_POSITION_MODE_FIXED ? scale : 1.0f));
            } else if strcmp(timelineName, "spacing") == 0 {
                spCurveTimeline1* timeline = &spPathConstraintSpacingTimeline_create(frames, frames, constraintIndex).super;
                spTimelineArray_add(timelines, SkeletonJson__readTimeline(keyMap, timeline, 0.0f, constraint.spacingMode == SP_SPACING_MODE_LENGTH || constraint.spacingMode == SP_SPACING_MODE_FIXED ? scale : 1.0f));
            } else if strcmp(timelineName, "mix") == 0 {
                spPathConstraintMixTimeline* timeline = spPathConstraintMixTimeline_create(frames, frames * 3, constraintIndex);
                f32 time = Json_getFloat(keyMap, "time", 0.0f);
                f32 mixRotate = Json_getFloat(keyMap, "mixRotate", 1.0f);
                f32 mixX = Json_getFloat(keyMap, "mixX", 1.0f);
                f32 mixY = Json_getFloat(keyMap, "mixY", mixX);
                {
                    frame = 0;
                    for bezier = 0; true; ++frame {
                        f32 time2;
                        f32 mixRotate2;
                        f32 mixX2;
                        f32 mixY2;
                        spPathConstraintMixTimeline_setFrame(timeline, frame, time, mixRotate, mixX, mixY);
                        nextMap = keyMap.next;
                        if nextMap == null {
                            break;
                        }
                        time2 = Json_getFloat(nextMap, "time", 0.0f);
                        mixRotate2 = Json_getFloat(nextMap, "mixRotate", 1.0f);
                        mixX2 = Json_getFloat(nextMap, "mixX", 1.0f);
                        mixY2 = Json_getFloat(nextMap, "mixY", mixX2);
                        curve = Json_getItem(keyMap, "curve");
                        if curve != null {
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 0, time, time2, mixRotate, mixRotate2, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 1, time, time2, mixX, mixX2, 1.0f);
                            bezier = readCurve(curve, &timeline.super, bezier, frame, 2, time, time2, mixY, mixY2, 1.0f);
                        }
                        time = time2;
                        mixRotate = mixRotate2;
                        mixX = mixX2;
                        mixY = mixY2;
                        keyMap = nextMap;
                    }
                }
                spTimelineArray_add(timelines, &timeline.super.super);
            }
        }
    }
    for constraintMap = physics != null ? physics.child : null; constraintMap != null; constraintMap = constraintMap.next {
        i32 index = -1;
        if constraintMap.name && strlen(constraintMap.name) > 0 {
            spPhysicsConstraintData* constraint = spSkeletonData_findPhysicsConstraint(skeletonData, constraintMap.name);
            index = findPhysicsConstraintIndex(self, skeletonData, constraint, timelines);
            if index == -1 {
                return null;
            }
        }
        for timelineMap = constraintMap.child; timelineMap != null; timelineMap = timelineMap.next {
            keyMap = timelineMap.child;
            if keyMap == null {
                continue;
            }
            u8* timelineName = timelineMap.name;
            i32 frames = timelineMap.size;
            if strcmp(timelineName, "reset") == 0 {
                spPhysicsConstraintResetTimeline* timeline = spPhysicsConstraintResetTimeline_create(frames, index);
                for frame = 0; keyMap != null; keyMap = keyMap.next {
                    spPhysicsConstraintResetTimeline_setFrame(timeline, frame, Json_getFloat(keyMap, "time", 0.0f));
                    frame++;
                }
                spTimelineArray_add(timelines, &timeline.super);
                continue;
            }
            spPhysicsConstraintTimeline* timeline = null;
            if strcmp(timelineName, "inertia") == 0 {
                timeline = spPhysicsConstraintTimeline_create(frames, frames, index, SP_TIMELINE_PHYSICSCONSTRAINT_INERTIA);
            } else if strcmp(timelineName, "strength") == 0 {
                timeline = spPhysicsConstraintTimeline_create(frames, frames, index, SP_TIMELINE_PHYSICSCONSTRAINT_STRENGTH);
            } else if strcmp(timelineName, "damping") == 0 {
                timeline = spPhysicsConstraintTimeline_create(frames, frames, index, SP_TIMELINE_PHYSICSCONSTRAINT_DAMPING);
            } else if strcmp(timelineName, "mass") == 0 {
                timeline = spPhysicsConstraintTimeline_create(frames, frames, index, SP_TIMELINE_PHYSICSCONSTRAINT_MASS);
            } else if strcmp(timelineName, "wind") == 0 {
                timeline = spPhysicsConstraintTimeline_create(frames, frames, index, SP_TIMELINE_PHYSICSCONSTRAINT_WIND);
            } else if strcmp(timelineName, "gravity") == 0 {
                timeline = spPhysicsConstraintTimeline_create(frames, frames, index, SP_TIMELINE_PHYSICSCONSTRAINT_GRAVITY);
            } else if strcmp(timelineName, "mix") == 0 {
                timeline = spPhysicsConstraintTimeline_create(frames, frames, index, SP_TIMELINE_PHYSICSCONSTRAINT_MIX);
            } else {
                continue;
            }
            spTimelineArray_add(timelines, SkeletonJson__readTimeline(keyMap, &timeline.super, 0.0f, 1.0f));
        }
    }
    for attachmentsMap = attachmentsJson != null ? attachmentsJson.child : null; attachmentsMap != null; attachmentsMap = attachmentsMap.next {
        spSkin* skin = spSkeletonData_findSkin(skeletonData, attachmentsMap.name);
        for slotMap = attachmentsMap.child; slotMap != null; slotMap = slotMap.next {
            Json* attachmentMap;
            i32 slotIndex = findSlotIndex(self, skeletonData, slotMap.name, timelines);
            if slotIndex == -1 {
                return null;
            }
            for attachmentMap = slotMap.child; attachmentMap != null; attachmentMap = attachmentMap.next {
                spAttachment* baseAttachment = spSkin_getAttachment(skin, slotIndex, attachmentMap.name);
                if baseAttachment == null {
                    cleanUpTimelines(timelines);
                    _spSkeletonJson_setError(self, null, "Attachment not found: ", attachmentMap.name);
                    return null;
                }
                for timelineMap = attachmentMap.child; timelineMap != null; timelineMap = timelineMap.next {
                    i32 frames;
                    u8* timelineName;
                    keyMap = timelineMap.child;
                    if keyMap == null {
                        continue;
                    }
                    frames = timelineMap.size;
                    timelineName = timelineMap.name;
                    if strcmp("deform", timelineName) == 0 {
                        f32* tempDeform;
                        spVertexAttachment* vertexAttachment;
                        i32 weighted;
                        i32 deformLength;
                        spDeformTimeline* timeline;
                        f32 time;
                        vertexAttachment = cast(spVertexAttachment*, baseAttachment);
                        weighted = vertexAttachment.bones != null;
                        deformLength = weighted != 0 ? vertexAttachment.verticesCount / 3 * 2 : vertexAttachment.verticesCount;
                        tempDeform = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * deformLength), "extension.h", 96));
                        timeline = spDeformTimeline_create(timelineMap.size, deformLength, timelineMap.size, slotIndex, vertexAttachment);
                        time = Json_getFloat(keyMap, "time", 0.0f);
                        {
                            frame = 0;
                            for bezier = 0; true; ++frame {
                                Json* vertices = Json_getItem(keyMap, "vertices");
                                f32* deform;
                                f32 time2;
                                if vertices == null {
                                    if weighted != 0 {
                                        deform = tempDeform;
                                        memset(deform, 0, cast(u64, sizeof(f32) * deformLength));
                                    } else {
                                        deform = vertexAttachment.vertices;
                                    }
                                } else {
                                    i32 v;
                                    i32 start = Json_getInt(keyMap, "offset", 0);
                                    Json* vertex;
                                    deform = tempDeform;
                                    memset(deform, 0, cast(u64, sizeof(f32) * start));
                                    if self.scale == 1.0f {
                                        {
                                            vertex = vertices.child;
                                            for v = start; vertex != null; vertex = vertex.next {
                                                deform[v] = vertex.valueFloat;
                                                ++v;
                                            }
                                        }
                                    } else {
                                        {
                                            vertex = vertices.child;
                                            for v = start; vertex != null; vertex = vertex.next {
                                                deform[v] = vertex.valueFloat * self.scale;
                                                ++v;
                                            }
                                        }
                                    }
                                    memset(deform + v, 0, cast(u64, sizeof(f32) * (deformLength - v)));
                                    if weighted == 0 {
                                        f32* verticesValues = vertexAttachment.vertices;
                                        for v = 0; v < deformLength; ++v {
                                            deform[v] += verticesValues[v];
                                        }
                                    }
                                }
                                spDeformTimeline_setFrame(timeline, frame, time, deform);
                                nextMap = keyMap.next;
                                if nextMap == null {
                                    break;
                                }
                                time2 = Json_getFloat(nextMap, "time", 0.0f);
                                curve = Json_getItem(keyMap, "curve");
                                if curve != null {
                                    bezier = readCurve(curve, &timeline.super, bezier, frame, 0, time, time2, 0.0f, 1.0f, 1.0f);
                                }
                                time = time2;
                                keyMap = nextMap;
                            }
                        }
                        _spFree(cast(void*, tempDeform));
                        spTimelineArray_add(timelines, &timeline.super.super);
                    } else if strcmp(timelineName, "sequence") == 0 {
                        spSequenceTimeline* timeline = spSequenceTimeline_create(frames, slotIndex, baseAttachment);
                        f32 lastDelay = 0.0f;
                        for frame = 0; keyMap != null; keyMap = keyMap.next {
                            f32 delay = Json_getFloat(keyMap, "delay", lastDelay);
                            f32 time = Json_getFloat(keyMap, "time", 0.0f);
                            u8* modeString = Json_getString(keyMap, "mode", "hold");
                            i32 index = Json_getInt(keyMap, "index", 0);
                            i32 mode = 0;
                            if strcmp(modeString, "once") == 0 {
                                mode = 1;
                            }
                            if strcmp(modeString, "loop") == 0 {
                                mode = 2;
                            }
                            if strcmp(modeString, "pingpong") == 0 {
                                mode = 3;
                            }
                            if strcmp(modeString, "onceReverse") == 0 {
                                mode = 4;
                            }
                            if strcmp(modeString, "loopReverse") == 0 {
                                mode = 5;
                            }
                            if strcmp(modeString, "pingpongReverse") == 0 {
                                mode = 6;
                            }
                            spSequenceTimeline_setFrame(timeline, frame, time, mode, index, delay);
                            lastDelay = delay;
                            frame++;
                        }
                        spTimelineArray_add(timelines, &timeline.super);
                    }
                }
            }
        }
    }
    if drawOrderJson != null {
        spDrawOrderTimeline* timeline = spDrawOrderTimeline_create(drawOrderJson.size, skeletonData.slotsCount);
        {
            keyMap = drawOrderJson.child;
            for frame = 0; keyMap != null; keyMap = keyMap.next {
                i32 ii;
                i32* drawOrder = null;
                Json* offsets = Json_getItem(keyMap, "offsets");
                if offsets != null {
                    Json* offsetMap;
                    var unchanged = cast(i32*, _spMalloc(cast(u64, sizeof(i32) * (skeletonData.slotsCount - offsets.size)), "extension.h", 96));
                    i32 originalIndex = 0;
                    i32 unchangedIndex = 0;
                    drawOrder = cast(i32*, _spMalloc(cast(u64, sizeof(i32) * skeletonData.slotsCount), "extension.h", 96));
                    for ii = skeletonData.slotsCount - 1; ii >= 0; --ii {
                        drawOrder[ii] = -1;
                    }
                    for offsetMap = offsets.child; offsetMap != null; offsetMap = offsetMap.next {
                        i32 slotIndex = findSlotIndex(self, skeletonData, Json_getString(offsetMap, "slot", null), timelines);
                        if slotIndex == -1 {
                            return null;
                        }
                        while originalIndex != slotIndex {
                            unchanged[unchangedIndex++] = originalIndex++;
                        }
                        drawOrder[originalIndex + Json_getInt(offsetMap, "offset", 0)] = originalIndex;
                        originalIndex++;
                    }
                    while originalIndex < skeletonData.slotsCount {
                        unchanged[unchangedIndex++] = originalIndex++;
                    }
                    for ii = skeletonData.slotsCount - 1; ii >= 0; ii-- {
                        if drawOrder[ii] == -1 {
                            drawOrder[ii] = unchanged[--unchangedIndex];
                        }
                    }
                    _spFree(cast(void*, unchanged));
                }
                spDrawOrderTimeline_setFrame(timeline, frame, Json_getFloat(keyMap, "time", 0.0f), drawOrder);
                _spFree(cast(void*, drawOrder));
                ++frame;
            }
        }
        spTimelineArray_add(timelines, &timeline.super);
    }
    if events != null {
        spEventTimeline* timeline = spEventTimeline_create(events.size);
        {
            keyMap = events.child;
            for frame = 0; keyMap != null; keyMap = keyMap.next {
                spEvent* event;
                u8* stringValue;
                spEventData* eventData = spSkeletonData_findEvent(skeletonData, Json_getString(keyMap, "name", null));
                if eventData == null {
                    cleanUpTimelines(timelines);
                    _spSkeletonJson_setError(self, null, "Event not found: ", Json_getString(keyMap, "name", null));
                    return null;
                }
                event = spEvent_create(Json_getFloat(keyMap, "time", 0.0f), eventData);
                event.intValue = Json_getInt(keyMap, "int", eventData.intValue);
                event.floatValue = Json_getFloat(keyMap, "float", eventData.floatValue);
                stringValue = Json_getString(keyMap, "string", eventData.stringValue);
                if stringValue != null {
                    event.stringValue = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(stringValue) + 1), "extension.h", 96));
                    strcpy(event.stringValue, stringValue);
                }
                if eventData.audioPath != null {
                    event.volume = Json_getFloat(keyMap, "volume", 1.0f);
                    event.balance = Json_getFloat(keyMap, "volume", 0.0f);
                }
                spEventTimeline_setFrame(timeline, frame, event);
                ++frame;
            }
        }
        spTimelineArray_add(timelines, &timeline.super);
    }
    duration = 0.0f;
    {
        i = 0;
        for n = timelines.size; i < n; ++i {
            duration = duration > spTimeline_getDuration(timelines.items[i]) ? duration : spTimeline_getDuration(timelines.items[i]);
        }
    }
    return spAnimation_create(root.name, timelines, duration);
}

void SkeletonJson___readVertices(spSkeletonJson* self, Json* attachmentMap, spVertexAttachment* attachment, i32 verticesLength) {
    Json* entry;
    f32* vertices;
    i32 i;
    i32 n;
    i32 nn;
    i32 entrySize;
    spFloatArray* weights;
    spIntArray* bones;
    attachment.worldVerticesLength = verticesLength;
    entry = Json_getItem(attachmentMap, "vertices");
    entrySize = entry.size;
    vertices = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * entrySize), "extension.h", 96));
    {
        entry = entry.child;
        for i = 0; entry != null; entry = entry.next {
            vertices[i] = entry.valueFloat;
            ++i;
        }
    }
    if verticesLength == entrySize {
        if self.scale != 1.0f {
            for i = 0; i < entrySize; ++i {
                vertices[i] *= self.scale;
            }
        }
        attachment.verticesCount = verticesLength;
        attachment.vertices = vertices;
        attachment.bonesCount = 0;
        attachment.bones = null;
        return;
    }
    weights = spFloatArray_create(verticesLength * 3 * 3);
    bones = spIntArray_create(verticesLength * 3);
    {
        i = 0;
        n = entrySize;
        while i < n {
            var boneCount = cast(i32, vertices[i++]);
            spIntArray_add(bones, boneCount);
            for nn = i + boneCount * 4; i < nn; i += 4 {
                spIntArray_add(bones, cast(i32, vertices[i]));
                spFloatArray_add(weights, vertices[i + 1] * self.scale);
                spFloatArray_add(weights, vertices[i + 2] * self.scale);
                spFloatArray_add(weights, vertices[i + 3]);
            }
        }
    }
    attachment.verticesCount = weights.size;
    attachment.vertices = weights.items;
    _spFree(cast(void*, weights));
    attachment.bonesCount = bones.size;
    attachment.bones = bones.items;
    _spFree(cast(void*, bones));
    _spFree(cast(void*, vertices));
}
}

spSkeletonData* spSkeletonJson_readSkeletonDataFile(spSkeletonJson* self, u8* path) {
    i32 length;
    spSkeletonData* skeletonData;
    u8* json = _spUtil_readFile(path, &length);
    if length == 0 || !json {
        _spSkeletonJson_setError(self, null, "Unable to read skeleton file: ", path);
        return null;
    }
    skeletonData = spSkeletonJson_readSkeletonData(self, json);
    _spFree(cast(void*, json));
    return skeletonData;
}

private {
i32 SkeletonJson__string_starts_with(u8* str_var, u8* needle) {
    i32 lenStr;
    i32 lenNeedle;
    i32 i;
    if str_var == null {
        return 0;
    }
    lenStr = cast(i32, strlen(str_var));
    lenNeedle = cast(i32, strlen(needle));
    if lenStr < lenNeedle {
        return 0;
    }
    for i = 0; i < lenNeedle; i++ {
        if str_var[i] != needle[i] {
            return 0;
        }
    }
    return -1;
}
}

spSkeletonData* spSkeletonJson_readSkeletonData(spSkeletonJson* self, u8* json) {
    i32 i;
    i32 ii;
    spSkeletonData* skeletonData;
    Json* root;
    Json* skeleton;
    Json* bones;
    Json* boneMap;
    Json* ik;
    Json* transform;
    Json* pathJson;
    Json* physics;
    Json* slots;
    Json* skins;
    Json* animations;
    Json* events;
    var internal = cast(_spSkeletonJson*, self);
    _spFree(cast(void*, self.error));
    self.error = null;
    internal.linkedMeshCount = 0;
    root = Json_create(json);
    if root == null {
        _spSkeletonJson_setError(self, null, "Invalid skeleton JSON: ", Json_getError());
        return null;
    }
    skeletonData = spSkeletonData_create();
    skeleton = Json_getItem(root, "skeleton");
    if skeleton != null {
        skeletonData.hash = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(Json_getString(skeleton, "hash", "0")) + 1), "extension.h", 96));
        strcpy(skeletonData.hash, Json_getString(skeleton, "hash", "0"));
        skeletonData.version = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(Json_getString(skeleton, "spine", "0")) + 1), "extension.h", 96));
        strcpy(skeletonData.version, Json_getString(skeleton, "spine", "0"));
        if SkeletonJson__string_starts_with(skeletonData.version, "4.2") == 0 {
            noinit u8[255] errorMsg;
            snprintf(errorMsg, 255, "Skeleton version %s does not match runtime version %s", skeletonData.version, "4.2");
            _spSkeletonJson_setError(self, null, errorMsg, null);
            return null;
        }
        skeletonData.x = Json_getFloat(skeleton, "x", 0.0f);
        skeletonData.y = Json_getFloat(skeleton, "y", 0.0f);
        skeletonData.width = Json_getFloat(skeleton, "width", 0.0f);
        skeletonData.height = Json_getFloat(skeleton, "height", 0.0f);
        skeletonData.referenceScale = Json_getFloat(skeleton, "referenceScale", 100.0f) * self.scale;
        skeletonData.fps = Json_getFloat(skeleton, "fps", 30.0f);
        skeletonData.imagesPath = Json_getString(skeleton, "images", null);
        if skeletonData.imagesPath != null {
            u8* tmp = null;
            tmp = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(skeletonData.imagesPath) + 1), "extension.h", 96));
            strcpy(tmp, skeletonData.imagesPath);
            skeletonData.imagesPath = tmp;
        }
        skeletonData.audioPath = Json_getString(skeleton, "audio", null);
        if skeletonData.audioPath != null {
            u8* tmp = null;
            tmp = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(skeletonData.audioPath) + 1), "extension.h", 96));
            strcpy(tmp, skeletonData.audioPath);
            skeletonData.audioPath = tmp;
        }
    }
    bones = Json_getItem(root, "bones");
    skeletonData.bones = cast(spBoneData**, _spMalloc(cast(u64, sizeof(spBoneData*) * bones.size), "extension.h", 96));
    {
        boneMap = bones.child;
        for i = 0; boneMap != null; boneMap = boneMap.next {
            spBoneData* data;
            u8* inherit;
            u8* color;
            spBoneData* parent = null;
            u8* parentName = Json_getString(boneMap, "parent", null);
            if parentName != null {
                parent = spSkeletonData_findBone(skeletonData, parentName);
                if parent == null {
                    spSkeletonData_dispose(skeletonData);
                    _spSkeletonJson_setError(self, root, "Parent bone not found: ", parentName);
                    return null;
                }
            }
            data = spBoneData_create(skeletonData.bonesCount, Json_getString(boneMap, "name", null), parent);
            data.length = Json_getFloat(boneMap, "length", 0.0f) * self.scale;
            data.x = Json_getFloat(boneMap, "x", 0.0f) * self.scale;
            data.y = Json_getFloat(boneMap, "y", 0.0f) * self.scale;
            data.rotation = Json_getFloat(boneMap, "rotation", 0.0f);
            data.scaleX = Json_getFloat(boneMap, "scaleX", 1.0f);
            data.scaleY = Json_getFloat(boneMap, "scaleY", 1.0f);
            data.shearX = Json_getFloat(boneMap, "shearX", 0.0f);
            data.shearY = Json_getFloat(boneMap, "shearY", 0.0f);
            inherit = Json_getString(boneMap, "inherit", "normal");
            data.inherit = SP_INHERIT_NORMAL;
            if strcmp(inherit, "normal") == 0 {
                data.inherit = SP_INHERIT_NORMAL;
            } else if strcmp(inherit, "onlyTranslation") == 0 {
                data.inherit = SP_INHERIT_ONLYTRANSLATION;
            } else if strcmp(inherit, "noRotationOrReflection") == 0 {
                data.inherit = SP_INHERIT_NOROTATIONORREFLECTION;
            } else if strcmp(inherit, "noScale") == 0 {
                data.inherit = SP_INHERIT_NOSCALE;
            } else if strcmp(inherit, "noScaleOrReflection") == 0 {
                data.inherit = SP_INHERIT_NOSCALEORREFLECTION;
            }
            data.skinRequired = Json_getInt(boneMap, "skin", 0) != 0 ? 1 : 0;
            color = Json_getString(boneMap, "color", null);
            if color != null {
                toColor2(&data.color, color, -1);
            }
            data.icon = Json_getString(boneMap, "icon", "");
            if data.icon != null {
                u8* tmp = null;
                tmp = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(data.icon) + 1), "extension.h", 96));
                strcpy(tmp, data.icon);
                data.icon = tmp;
            }
            data.visible = Json_getInt(boneMap, "visible", -1) != 0 ? -1 : 0;
            skeletonData.bones[i] = data;
            skeletonData.bonesCount++;
            ++i;
        }
    }
    slots = Json_getItem(root, "slots");
    if slots != null {
        Json* slotMap;
        skeletonData.slots = cast(spSlotData**, _spMalloc(cast(u64, sizeof(spSlotData*) * slots.size), "extension.h", 96));
        {
            slotMap = slots.child;
            for i = 0; slotMap != null; slotMap = slotMap.next {
                spSlotData* data;
                u8* color;
                u8* dark;
                Json* item;
                u8* boneName = Json_getString(slotMap, "bone", null);
                spBoneData* boneData = spSkeletonData_findBone(skeletonData, boneName);
                if boneData == null {
                    spSkeletonData_dispose(skeletonData);
                    _spSkeletonJson_setError(self, root, "Slot bone not found: ", boneName);
                    return null;
                }
                var slotName = Json_getString(slotMap, "name", null);
                data = spSlotData_create(i, slotName, boneData);
                color = Json_getString(slotMap, "color", null);
                if color != null {
                    spColor_setFromFloats(&data.color, toColor(color, 0), toColor(color, 1), toColor(color, 2), toColor(color, 3));
                }
                dark = Json_getString(slotMap, "dark", null);
                if dark != null {
                    data.darkColor = spColor_create();
                    spColor_setFromFloats(data.darkColor, toColor(dark, 0), toColor(dark, 1), toColor(dark, 2), 1.0f);
                }
                item = Json_getItem(slotMap, "attachment");
                if item != null {
                    spSlotData_setAttachmentName(data, item.valueString);
                }
                item = Json_getItem(slotMap, "blend");
                if item != null {
                    if strcmp(item.valueString, "additive") == 0 {
                        data.blendMode = SP_BLEND_MODE_ADDITIVE;
                    } else if strcmp(item.valueString, "multiply") == 0 {
                        data.blendMode = SP_BLEND_MODE_MULTIPLY;
                    } else if strcmp(item.valueString, "screen") == 0 {
                        data.blendMode = SP_BLEND_MODE_SCREEN;
                    }
                }
                data.visible = Json_getInt(slotMap, "visible", -1);
                skeletonData.slots[i] = data;
                skeletonData.slotsCount++;
                ++i;
            }
        }
    }
    ik = Json_getItem(root, "ik");
    if ik != null {
        Json* constraintMap;
        skeletonData.ikConstraints = cast(spIkConstraintData**, _spMalloc(cast(u64, sizeof(spIkConstraintData*) * ik.size), "extension.h", 96));
        {
            constraintMap = ik.child;
            for i = 0; constraintMap != null; constraintMap = constraintMap.next {
                u8* targetName;
                spIkConstraintData* data = spIkConstraintData_create(Json_getString(constraintMap, "name", null));
                data.order = Json_getInt(constraintMap, "order", 0);
                data.skinRequired = Json_getInt(constraintMap, "skin", 0) != 0 ? 1 : 0;
                boneMap = Json_getItem(constraintMap, "bones");
                data.bonesCount = boneMap.size;
                data.bones = cast(spBoneData**, _spMalloc(cast(u64, sizeof(spBoneData*) * boneMap.size), "extension.h", 96));
                {
                    boneMap = boneMap.child;
                    for ii = 0; boneMap != null; boneMap = boneMap.next {
                        data.bones[ii] = spSkeletonData_findBone(skeletonData, boneMap.valueString);
                        if data.bones[ii] == null {
                            spIkConstraintData_dispose(data);
                            spSkeletonData_dispose(skeletonData);
                            _spSkeletonJson_setError(self, root, "IK bone not found: ", boneMap.valueString);
                            return null;
                        }
                        ++ii;
                    }
                }
                targetName = Json_getString(constraintMap, "target", null);
                data.target = spSkeletonData_findBone(skeletonData, targetName);
                if data.target == null {
                    spIkConstraintData_dispose(data);
                    spSkeletonData_dispose(skeletonData);
                    _spSkeletonJson_setError(self, root, "Target bone not found: ", targetName);
                    return null;
                }
                data.bendDirection = Json_getInt(constraintMap, "bendPositive", 1) != 0 ? 1 : -1;
                data.compress = Json_getInt(constraintMap, "compress", 0) != 0 ? 1 : 0;
                data.stretch = Json_getInt(constraintMap, "stretch", 0) != 0 ? 1 : 0;
                data.uniform = Json_getInt(constraintMap, "uniform", 0) != 0 ? 1 : 0;
                data.mix = Json_getFloat(constraintMap, "mix", 1.0f);
                data.softness = Json_getFloat(constraintMap, "softness", 0.0f) * self.scale;
                skeletonData.ikConstraints[i] = data;
                skeletonData.ikConstraintsCount++;
                ++i;
            }
        }
    }
    transform = Json_getItem(root, "transform");
    if transform != null {
        Json* constraintMap;
        skeletonData.transformConstraints = cast(spTransformConstraintData**, _spMalloc(cast(u64, sizeof(spTransformConstraintData*) * transform.size), "extension.h", 96));
        {
            constraintMap = transform.child;
            for i = 0; constraintMap != null; constraintMap = constraintMap.next {
                u8* name;
                spTransformConstraintData* data = spTransformConstraintData_create(Json_getString(constraintMap, "name", null));
                data.order = Json_getInt(constraintMap, "order", 0);
                data.skinRequired = Json_getInt(constraintMap, "skin", 0) != 0 ? 1 : 0;
                boneMap = Json_getItem(constraintMap, "bones");
                data.bonesCount = boneMap.size;
                data.bones = cast(spBoneData**, _spMalloc(cast(u64, sizeof(spBoneData*) * boneMap.size), "extension.h", 96));
                {
                    boneMap = boneMap.child;
                    for ii = 0; boneMap != null; boneMap = boneMap.next {
                        data.bones[ii] = spSkeletonData_findBone(skeletonData, boneMap.valueString);
                        if data.bones[ii] == null {
                            spTransformConstraintData_dispose(data);
                            spSkeletonData_dispose(skeletonData);
                            _spSkeletonJson_setError(self, root, "Transform bone not found: ", boneMap.valueString);
                            return null;
                        }
                        ++ii;
                    }
                }
                name = Json_getString(constraintMap, "target", null);
                data.target = spSkeletonData_findBone(skeletonData, name);
                if data.target == null {
                    spTransformConstraintData_dispose(data);
                    spSkeletonData_dispose(skeletonData);
                    _spSkeletonJson_setError(self, root, "Target bone not found: ", name);
                    return null;
                }
                data.local = Json_getInt(constraintMap, "local", 0);
                data.relative = Json_getInt(constraintMap, "relative", 0);
                data.offsetRotation = Json_getFloat(constraintMap, "rotation", 0.0f);
                data.offsetX = Json_getFloat(constraintMap, "x", 0.0f) * self.scale;
                data.offsetY = Json_getFloat(constraintMap, "y", 0.0f) * self.scale;
                data.offsetScaleX = Json_getFloat(constraintMap, "scaleX", 0.0f);
                data.offsetScaleY = Json_getFloat(constraintMap, "scaleY", 0.0f);
                data.offsetShearY = Json_getFloat(constraintMap, "shearY", 0.0f);
                data.mixRotate = Json_getFloat(constraintMap, "mixRotate", 1.0f);
                data.mixX = Json_getFloat(constraintMap, "mixX", 1.0f);
                data.mixY = Json_getFloat(constraintMap, "mixY", data.mixX);
                data.mixScaleX = Json_getFloat(constraintMap, "mixScaleX", 1.0f);
                data.mixScaleY = Json_getFloat(constraintMap, "mixScaleY", data.mixScaleX);
                data.mixShearY = Json_getFloat(constraintMap, "mixShearY", 1.0f);
                skeletonData.transformConstraints[i] = data;
                skeletonData.transformConstraintsCount++;
                ++i;
            }
        }
    }
    pathJson = Json_getItem(root, "path");
    if pathJson != null {
        Json* constraintMap;
        skeletonData.pathConstraints = cast(spPathConstraintData**, _spMalloc(cast(u64, sizeof(spPathConstraintData*) * pathJson.size), "extension.h", 96));
        {
            constraintMap = pathJson.child;
            for i = 0; constraintMap != null; constraintMap = constraintMap.next {
                u8* name;
                u8* item;
                spPathConstraintData* data = spPathConstraintData_create(Json_getString(constraintMap, "name", null));
                data.order = Json_getInt(constraintMap, "order", 0);
                data.skinRequired = Json_getInt(constraintMap, "skin", 0) != 0 ? 1 : 0;
                boneMap = Json_getItem(constraintMap, "bones");
                data.bonesCount = boneMap.size;
                data.bones = cast(spBoneData**, _spMalloc(cast(u64, sizeof(spBoneData*) * boneMap.size), "extension.h", 96));
                {
                    boneMap = boneMap.child;
                    for ii = 0; boneMap != null; boneMap = boneMap.next {
                        data.bones[ii] = spSkeletonData_findBone(skeletonData, boneMap.valueString);
                        if data.bones[ii] == null {
                            spPathConstraintData_dispose(data);
                            spSkeletonData_dispose(skeletonData);
                            _spSkeletonJson_setError(self, root, "Path bone not found: ", boneMap.valueString);
                            return null;
                        }
                        ++ii;
                    }
                }
                name = Json_getString(constraintMap, "target", null);
                data.target = spSkeletonData_findSlot(skeletonData, name);
                if data.target == null {
                    spPathConstraintData_dispose(data);
                    spSkeletonData_dispose(skeletonData);
                    _spSkeletonJson_setError(self, root, "Target slot not found: ", name);
                    return null;
                }
                item = Json_getString(constraintMap, "positionMode", "percent");
                if strcmp(item, "fixed") == 0 {
                    data.positionMode = SP_POSITION_MODE_FIXED;
                } else if strcmp(item, "percent") == 0 {
                    data.positionMode = SP_POSITION_MODE_PERCENT;
                }
                item = Json_getString(constraintMap, "spacingMode", "length");
                if strcmp(item, "length") == 0 {
                    data.spacingMode = SP_SPACING_MODE_LENGTH;
                } else if strcmp(item, "fixed") == 0 {
                    data.spacingMode = SP_SPACING_MODE_FIXED;
                } else if strcmp(item, "percent") == 0 {
                    data.spacingMode = SP_SPACING_MODE_PERCENT;
                } else {
                    data.spacingMode = SP_SPACING_MODE_PROPORTIONAL;
                }
                item = Json_getString(constraintMap, "rotateMode", "tangent");
                if strcmp(item, "tangent") == 0 {
                    data.rotateMode = SP_ROTATE_MODE_TANGENT;
                } else if strcmp(item, "chain") == 0 {
                    data.rotateMode = SP_ROTATE_MODE_CHAIN;
                } else if strcmp(item, "chainScale") == 0 {
                    data.rotateMode = SP_ROTATE_MODE_CHAIN_SCALE;
                }
                data.offsetRotation = Json_getFloat(constraintMap, "rotation", 0.0f);
                data.position = Json_getFloat(constraintMap, "position", 0.0f);
                if data.positionMode == SP_POSITION_MODE_FIXED {
                    data.position *= self.scale;
                }
                data.spacing = Json_getFloat(constraintMap, "spacing", 0.0f);
                if data.spacingMode == SP_SPACING_MODE_LENGTH || data.spacingMode == SP_SPACING_MODE_FIXED {
                    data.spacing *= self.scale;
                }
                data.mixRotate = Json_getFloat(constraintMap, "mixRotate", 1.0f);
                data.mixX = Json_getFloat(constraintMap, "mixX", 1.0f);
                data.mixY = Json_getFloat(constraintMap, "mixY", data.mixX);
                skeletonData.pathConstraints[i] = data;
                skeletonData.pathConstraintsCount++;
                ++i;
            }
        }
    }
    physics = Json_getItem(root, "physics");
    if physics != null {
        Json* constraintMap;
        skeletonData.physicsConstraintsCount = physics.size;
        skeletonData.physicsConstraints = cast(spPhysicsConstraintData**, _spMalloc(cast(u64, sizeof(spPhysicsConstraintData*) * physics.size), "extension.h", 96));
        {
            constraintMap = physics.child;
            for i = 0; constraintMap != null; constraintMap = constraintMap.next {
                u8* name;
                spPhysicsConstraintData* data = spPhysicsConstraintData_create(Json_getString(constraintMap, "name", null));
                data.order = Json_getInt(constraintMap, "order", 0);
                data.skinRequired = Json_getInt(constraintMap, "skin", 0);
                name = Json_getString(constraintMap, "bone", null);
                data.bone = spSkeletonData_findBone(skeletonData, name);
                if data.bone == null {
                    spSkeletonData_dispose(skeletonData);
                    _spSkeletonJson_setError(self, root, "Physics bone not found: ", name);
                    return null;
                }
                data.x = Json_getFloat(constraintMap, "x", 0.0f);
                data.y = Json_getFloat(constraintMap, "y", 0.0f);
                data.rotate = Json_getFloat(constraintMap, "rotate", 0.0f);
                data.scaleX = Json_getFloat(constraintMap, "scaleX", 0.0f);
                data.shearX = Json_getFloat(constraintMap, "shearX", 0.0f);
                data.limit = Json_getFloat(constraintMap, "limit", 5000.0f) * self.scale;
                data.step = 1.0f / cast(f32, Json_getInt(constraintMap, "fps", 60));
                data.inertia = Json_getFloat(constraintMap, "inertia", 1.0f);
                data.strength = Json_getFloat(constraintMap, "strength", 100.0f);
                data.damping = Json_getFloat(constraintMap, "damping", 1.0f);
                data.massInverse = 1.0f / Json_getFloat(constraintMap, "mass", 1.0f);
                data.wind = Json_getFloat(constraintMap, "wind", 0.0f);
                data.gravity = Json_getFloat(constraintMap, "gravity", 0.0f);
                data.mix = Json_getFloat(constraintMap, "mix", 1.0f);
                data.inertiaGlobal = Json_getInt(constraintMap, "inertiaGlobal", 0);
                data.strengthGlobal = Json_getInt(constraintMap, "strengthGlobal", 0);
                data.dampingGlobal = Json_getInt(constraintMap, "dampingGlobal", 0);
                data.massGlobal = Json_getInt(constraintMap, "massGlobal", 0);
                data.windGlobal = Json_getInt(constraintMap, "windGlobal", 0);
                data.gravityGlobal = Json_getInt(constraintMap, "gravityGlobal", 0);
                data.mixGlobal = Json_getInt(constraintMap, "mixGlobal", 0);
                skeletonData.physicsConstraints[i] = data;
                ++i;
            }
        }
    }
    skins = Json_getItem(root, "skins");
    if skins != null {
        Json* skinMap;
        skeletonData.skins = cast(spSkin**, _spMalloc(cast(u64, sizeof(spSkin*) * skins.size), "extension.h", 96));
        {
            skinMap = skins.child;
            for i = 0; skinMap != null; skinMap = skinMap.next {
                Json* attachmentsMap;
                Json* curves;
                Json* skinPart;
                spSkin* skin = spSkin_create(Json_getString(skinMap, "name", ""));
                skinPart = Json_getItem(skinMap, "bones");
                if skinPart != null {
                    for skinPart = skinPart.child; skinPart != null; skinPart = skinPart.next {
                        spBoneData* bone = spSkeletonData_findBone(skeletonData, skinPart.valueString);
                        if bone == null {
                            spSkin_dispose(skin);
                            spSkeletonData_dispose(skeletonData);
                            _spSkeletonJson_setError(self, root, "Skin bone constraint not found: ", skinPart.valueString);
                            return null;
                        }
                        spBoneDataArray_add(skin.bones, bone);
                    }
                }
                skinPart = Json_getItem(skinMap, "ik");
                if skinPart != null {
                    for skinPart = skinPart.child; skinPart != null; skinPart = skinPart.next {
                        spIkConstraintData* constraint = spSkeletonData_findIkConstraint(skeletonData, skinPart.valueString);
                        if constraint == null {
                            spSkin_dispose(skin);
                            spSkeletonData_dispose(skeletonData);
                            _spSkeletonJson_setError(self, root, "Skin IK constraint not found: ", skinPart.valueString);
                            return null;
                        }
                        spIkConstraintDataArray_add(skin.ikConstraints, constraint);
                    }
                }
                skinPart = Json_getItem(skinMap, "path");
                if skinPart != null {
                    for skinPart = skinPart.child; skinPart != null; skinPart = skinPart.next {
                        spPathConstraintData* constraint = spSkeletonData_findPathConstraint(skeletonData, skinPart.valueString);
                        if constraint == null {
                            spSkin_dispose(skin);
                            spSkeletonData_dispose(skeletonData);
                            _spSkeletonJson_setError(self, root, "Skin path constraint not found: ", skinPart.valueString);
                            return null;
                        }
                        spPathConstraintDataArray_add(skin.pathConstraints, constraint);
                    }
                }
                skinPart = Json_getItem(skinMap, "transform");
                if skinPart != null {
                    for skinPart = skinPart.child; skinPart != null; skinPart = skinPart.next {
                        spTransformConstraintData* constraint = spSkeletonData_findTransformConstraint(skeletonData, skinPart.valueString);
                        if constraint == null {
                            spSkin_dispose(skin);
                            spSkeletonData_dispose(skeletonData);
                            _spSkeletonJson_setError(self, root, "Skin transform constraint not found: ", skinPart.valueString);
                            return null;
                        }
                        spTransformConstraintDataArray_add(skin.transformConstraints, constraint);
                    }
                }
                skinPart = Json_getItem(skinMap, "physics");
                if skinPart != null {
                    for skinPart = skinPart.child; skinPart != null; skinPart = skinPart.next {
                        spPhysicsConstraintData* constraint = spSkeletonData_findPhysicsConstraint(skeletonData, skinPart.valueString);
                        if constraint == null {
                            spSkeletonData_dispose(skeletonData);
                            _spSkeletonJson_setError(self, root, "Skin physics constraint not found: ", skinPart.valueString);
                            return null;
                        }
                        spPhysicsConstraintDataArray_add(skin.physicsConstraints, constraint);
                    }
                }
                skeletonData.skins[skeletonData.skinsCount++] = skin;
                if strcmp(skin.name, "default") == 0 {
                    skeletonData.defaultSkin = skin;
                }
                skinPart = Json_getItem(skinMap, "attachments");
                if skinPart != null {
                    for attachmentsMap = skinPart.child; attachmentsMap != null; attachmentsMap = attachmentsMap.next {
                        spSlotData* slot = spSkeletonData_findSlot(skeletonData, attachmentsMap.name);
                        Json* attachmentMap;
                        for attachmentMap = attachmentsMap.child; attachmentMap != null; attachmentMap = attachmentMap.next {
                            spAttachment* attachment;
                            u8* skinAttachmentName = attachmentMap.name;
                            u8* attachmentName = Json_getString(attachmentMap, "name", skinAttachmentName);
                            u8* path = Json_getString(attachmentMap, "path", attachmentName);
                            u8* color;
                            Json* entry;
                            spSequence* sequence;
                            u8* typeString = Json_getString(attachmentMap, "type", "region");
                            spAttachmentType type;
                            if strcmp(typeString, "region") == 0 {
                                type = SP_ATTACHMENT_REGION;
                            } else if strcmp(typeString, "mesh") == 0 {
                                type = SP_ATTACHMENT_MESH;
                            } else if strcmp(typeString, "linkedmesh") == 0 {
                                type = SP_ATTACHMENT_LINKED_MESH;
                            } else if strcmp(typeString, "boundingbox") == 0 {
                                type = SP_ATTACHMENT_BOUNDING_BOX;
                            } else if strcmp(typeString, "path") == 0 {
                                type = SP_ATTACHMENT_PATH;
                            } else if strcmp(typeString, "clipping") == 0 {
                                type = SP_ATTACHMENT_CLIPPING;
                            } else if strcmp(typeString, "point") == 0 {
                                type = SP_ATTACHMENT_POINT;
                            } else {
                                spSkeletonData_dispose(skeletonData);
                                _spSkeletonJson_setError(self, root, "Unknown attachment type: ", typeString);
                                return null;
                            }
                            sequence = SkeletonJson__readSequence(Json_getItem(attachmentMap, "sequence"));
                            attachment = spAttachmentLoader_createAttachment(self.attachmentLoader, skin, type, attachmentName, path, sequence);
                            if attachment == null {
                                if self.attachmentLoader.error1 != null {
                                    spSkeletonData_dispose(skeletonData);
                                    _spSkeletonJson_setError(self, root, self.attachmentLoader.error1, self.attachmentLoader.error2);
                                    return null;
                                }
                                continue;
                            }
                            switch attachment.type {
                                case SP_ATTACHMENT_REGION: {
                                    {
                                        var region = cast(spRegionAttachment*, attachment);
                                        if path != null {
                                            region.path = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(path) + 1), "extension.h", 96));
                                            strcpy(region.path, path);
                                        }
                                        region.x = Json_getFloat(attachmentMap, "x", 0.0f) * self.scale;
                                        region.y = Json_getFloat(attachmentMap, "y", 0.0f) * self.scale;
                                        region.scaleX = Json_getFloat(attachmentMap, "scaleX", 1.0f);
                                        region.scaleY = Json_getFloat(attachmentMap, "scaleY", 1.0f);
                                        region.rotation = Json_getFloat(attachmentMap, "rotation", 0.0f);
                                        region.width = Json_getFloat(attachmentMap, "width", 32.0f) * self.scale;
                                        region.height = Json_getFloat(attachmentMap, "height", 32.0f) * self.scale;
                                        region.sequence = sequence;
                                        color = Json_getString(attachmentMap, "color", null);
                                        if color != null {
                                            spColor_setFromFloats(&region.color, toColor(color, 0), toColor(color, 1), toColor(color, 2), toColor(color, 3));
                                        }
                                        if region.region != null {
                                            spRegionAttachment_updateRegion(region);
                                        }
                                        spAttachmentLoader_configureAttachment(self.attachmentLoader, attachment);
                                        break case;
                                    }
                                }
                                case SP_ATTACHMENT_MESH, SP_ATTACHMENT_LINKED_MESH: {
                                    {
                                        var mesh = cast(spMeshAttachment*, attachment);
                                        mesh.path = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(path) + 1), "extension.h", 96));
                                        strcpy(mesh.path, path);
                                        color = Json_getString(attachmentMap, "color", null);
                                        if color != null {
                                            spColor_setFromFloats(&mesh.color, toColor(color, 0), toColor(color, 1), toColor(color, 2), toColor(color, 3));
                                        }
                                        mesh.width = Json_getFloat(attachmentMap, "width", 32.0f) * self.scale;
                                        mesh.height = Json_getFloat(attachmentMap, "height", 32.0f) * self.scale;
                                        mesh.sequence = sequence;
                                        entry = Json_getItem(attachmentMap, "parent");
                                        if entry == null {
                                            i32 verticesLength;
                                            entry = Json_getItem(attachmentMap, "triangles");
                                            mesh.trianglesCount = entry.size;
                                            mesh.triangles = cast(u16*, _spMalloc(cast(u64, sizeof(u16) * entry.size), "extension.h", 96));
                                            {
                                                entry = entry.child;
                                                for ii = 0; entry != null; entry = entry.next {
                                                    mesh.triangles[ii] = cast(u16, entry.valueInt);
                                                    ++ii;
                                                }
                                            }
                                            entry = Json_getItem(attachmentMap, "uvs");
                                            verticesLength = entry.size;
                                            mesh.regionUVs = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * verticesLength), "extension.h", 96));
                                            {
                                                entry = entry.child;
                                                for ii = 0; entry != null; entry = entry.next {
                                                    mesh.regionUVs[ii] = entry.valueFloat;
                                                    ++ii;
                                                }
                                            }
                                            SkeletonJson___readVertices(self, attachmentMap, &mesh.super, verticesLength);
                                            if mesh.region != null {
                                                spMeshAttachment_updateRegion(mesh);
                                            }
                                            mesh.hullLength = Json_getInt(attachmentMap, "hull", 0);
                                            entry = Json_getItem(attachmentMap, "edges");
                                            if entry != null {
                                                mesh.edgesCount = entry.size;
                                                mesh.edges = cast(u16*, _spMalloc(cast(u64, sizeof(u16) * entry.size), "extension.h", 96));
                                                {
                                                    entry = entry.child;
                                                    for ii = 0; entry != null; entry = entry.next {
                                                        mesh.edges[ii] = cast(u16, entry.valueInt);
                                                        ++ii;
                                                    }
                                                }
                                            }
                                            spAttachmentLoader_configureAttachment(self.attachmentLoader, attachment);
                                        } else {
                                            i32 inheritTimelines = Json_getInt(attachmentMap, "timelines", 1);
                                            _spSkeletonJson_addLinkedMesh(self, cast(spMeshAttachment*, attachment), Json_getString(attachmentMap, "skin", null), slot.index, entry.valueString, inheritTimelines);
                                        }
                                        break case;
                                    }
                                }
                                case SP_ATTACHMENT_BOUNDING_BOX: {
                                    {
                                        var box = cast(spBoundingBoxAttachment*, attachment);
                                        i32 vertexCount = Json_getInt(attachmentMap, "vertexCount", 0) << 1;
                                        SkeletonJson___readVertices(self, attachmentMap, &box.super, vertexCount);
                                        box.super.verticesCount = vertexCount;
                                        color = Json_getString(attachmentMap, "color", null);
                                        if color != null {
                                            spColor_setFromFloats(&box.color, toColor(color, 0), toColor(color, 1), toColor(color, 2), toColor(color, 3));
                                        }
                                        spAttachmentLoader_configureAttachment(self.attachmentLoader, attachment);
                                        break case;
                                    }
                                }
                                case SP_ATTACHMENT_PATH: {
                                    {
                                        var pathAttachment = cast(spPathAttachment*, attachment);
                                        i32 vertexCount = 0;
                                        pathAttachment.closed = Json_getInt(attachmentMap, "closed", 0);
                                        pathAttachment.constantSpeed = Json_getInt(attachmentMap, "constantSpeed", 1);
                                        vertexCount = Json_getInt(attachmentMap, "vertexCount", 0);
                                        SkeletonJson___readVertices(self, attachmentMap, &pathAttachment.super, vertexCount << 1);
                                        pathAttachment.lengthsLength = vertexCount / 3;
                                        pathAttachment.lengths = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * pathAttachment.lengthsLength), "extension.h", 96));
                                        curves = Json_getItem(attachmentMap, "lengths");
                                        {
                                            curves = curves.child;
                                            for ii = 0; curves != null; curves = curves.next {
                                                pathAttachment.lengths[ii] = curves.valueFloat * self.scale;
                                                ++ii;
                                            }
                                        }
                                        color = Json_getString(attachmentMap, "color", null);
                                        if color != null {
                                            spColor_setFromFloats(&pathAttachment.color, toColor(color, 0), toColor(color, 1), toColor(color, 2), toColor(color, 3));
                                        }
                                        break case;
                                    }
                                }
                                case SP_ATTACHMENT_POINT: {
                                    {
                                        var point = cast(spPointAttachment*, attachment);
                                        point.x = Json_getFloat(attachmentMap, "x", 0.0f) * self.scale;
                                        point.y = Json_getFloat(attachmentMap, "y", 0.0f) * self.scale;
                                        point.rotation = Json_getFloat(attachmentMap, "rotation", 0.0f);
                                        color = Json_getString(attachmentMap, "color", null);
                                        if color != null {
                                            spColor_setFromFloats(&point.color, toColor(color, 0), toColor(color, 1), toColor(color, 2), toColor(color, 3));
                                        }
                                        break case;
                                    }
                                }
                                case SP_ATTACHMENT_CLIPPING: {
                                    {
                                        var clip = cast(spClippingAttachment*, attachment);
                                        i32 vertexCount = 0;
                                        u8* end = Json_getString(attachmentMap, "end", null);
                                        if end != null {
                                            spSlotData* endSlot = spSkeletonData_findSlot(skeletonData, end);
                                            clip.endSlot = endSlot;
                                        }
                                        vertexCount = Json_getInt(attachmentMap, "vertexCount", 0) << 1;
                                        SkeletonJson___readVertices(self, attachmentMap, &clip.super, vertexCount);
                                        color = Json_getString(attachmentMap, "color", null);
                                        if color != null {
                                            spColor_setFromFloats(&clip.color, toColor(color, 0), toColor(color, 1), toColor(color, 2), toColor(color, 3));
                                        }
                                        spAttachmentLoader_configureAttachment(self.attachmentLoader, attachment);
                                        break case;
                                    }
                                }
                            }
                            spSkin_setAttachment(skin, slot.index, skinAttachmentName, attachment);
                        }
                    }
                }
                ++i;
            }
        }
    }
    for i = 0; i < internal.linkedMeshCount; ++i {
        spAttachment* parent;
        _spLinkedMesh* linkedMesh = internal.linkedMeshes + i;
        spSkin* skin = linkedMesh.skin == null ? skeletonData.defaultSkin : spSkeletonData_findSkin(skeletonData, linkedMesh.skin);
        if skin == null {
            spSkeletonData_dispose(skeletonData);
            _spSkeletonJson_setError(self, root, "Skin not found: ", linkedMesh.skin);
            return null;
        }
        parent = spSkin_getAttachment(skin, linkedMesh.slotIndex, linkedMesh.parent);
        if parent == null {
            spSkeletonData_dispose(skeletonData);
            _spSkeletonJson_setError(self, root, "Parent mesh not found: ", linkedMesh.parent);
            return null;
        }
        linkedMesh.mesh.super.timelineAttachment = linkedMesh.inheritTimeline != 0 ? parent : &linkedMesh.mesh.super.super;
        spMeshAttachment_setParentMesh(linkedMesh.mesh, cast(spMeshAttachment*, parent));
        if linkedMesh.mesh.region != null {
            spMeshAttachment_updateRegion(linkedMesh.mesh);
        }
        spAttachmentLoader_configureAttachment(self.attachmentLoader, &linkedMesh.mesh.super.super);
    }
    events = Json_getItem(root, "events");
    if events != null {
        Json* eventMap;
        u8* stringValue;
        u8* audioPath;
        skeletonData.eventsCount = events.size;
        skeletonData.events = cast(spEventData**, _spMalloc(cast(u64, sizeof(spEventData*) * events.size), "extension.h", 96));
        {
            eventMap = events.child;
            for i = 0; eventMap != null; eventMap = eventMap.next {
                spEventData* eventData = spEventData_create(eventMap.name);
                eventData.intValue = Json_getInt(eventMap, "int", 0);
                eventData.floatValue = Json_getFloat(eventMap, "float", 0.0f);
                stringValue = Json_getString(eventMap, "string", null);
                if stringValue != null {
                    eventData.stringValue = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(stringValue) + 1), "extension.h", 96));
                    strcpy(eventData.stringValue, stringValue);
                }
                audioPath = Json_getString(eventMap, "audio", null);
                if audioPath != null {
                    eventData.audioPath = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(audioPath) + 1), "extension.h", 96));
                    strcpy(eventData.audioPath, audioPath);
                    eventData.volume = Json_getFloat(eventMap, "volume", 1.0f);
                    eventData.balance = Json_getFloat(eventMap, "balance", 0.0f);
                }
                skeletonData.events[i] = eventData;
                ++i;
            }
        }
    }
    animations = Json_getItem(root, "animations");
    if animations != null {
        Json* animationMap;
        skeletonData.animations = cast(spAnimation**, _spMalloc(cast(u64, sizeof(spAnimation*) * animations.size), "extension.h", 96));
        for animationMap = animations.child; animationMap != null; animationMap = animationMap.next {
            spAnimation* animation = _spSkeletonJson_readAnimation(self, animationMap, skeletonData);
            if animation == null {
                spSkeletonData_dispose(skeletonData);
                _spSkeletonJson_setError(self, root, "Animation broken: ", animationMap.name);
                return null;
            }
            skeletonData.animations[skeletonData.animationsCount++] = animation;
        }
    }
    Json_dispose(root);
    return skeletonData;
}

spBoneDataArray* spBoneDataArray_create(i32 initialCapacity) {
    var array = cast(spBoneDataArray*, _spCalloc(1, cast(u64, sizeof(spBoneDataArray)), "extension.h", 95));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spBoneData**, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spBoneData*)), "extension.h", 95));
    return array;
}

void spBoneDataArray_dispose(spBoneDataArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spBoneDataArray_clear(spBoneDataArray* self) {
    self.size = 0;
}

spBoneDataArray* spBoneDataArray_setSize(spBoneDataArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spBoneData**, _spRealloc(self.items, cast(u64, sizeof(spBoneData*) * self.capacity)));
    }
    return self;
}

void spBoneDataArray_ensureCapacity(spBoneDataArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spBoneData**, _spRealloc(self.items, cast(u64, sizeof(spBoneData*) * self.capacity)));
}

void spBoneDataArray_add(spBoneDataArray* self, spBoneData* value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spBoneData**, _spRealloc(self.items, cast(u64, sizeof(spBoneData*) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spBoneDataArray_addAll(spBoneDataArray* self, spBoneDataArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spBoneDataArray_add(self, other.items[i]);
    }
}

void spBoneDataArray_addAllValues(spBoneDataArray* self, spBoneData** values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spBoneDataArray_add(self, values[i]);
    }
}

void spBoneDataArray_removeAt(spBoneDataArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spBoneData*) * (self.size - index)));
}

i32 spBoneDataArray_contains(spBoneDataArray* self, spBoneData* value) {
    spBoneData** items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spBoneData* spBoneDataArray_pop(spBoneDataArray* self) {
    spBoneData* item = self.items[--self.size];
    return item;
}

spBoneData* spBoneDataArray_peek(spBoneDataArray* self) {
    return self.items[self.size - 1];
}

spIkConstraintDataArray* spIkConstraintDataArray_create(i32 initialCapacity) {
    var array = cast(spIkConstraintDataArray*, _spCalloc(1, cast(u64, sizeof(spIkConstraintDataArray)), "extension.h", 95));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spIkConstraintData**, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spIkConstraintData*)), "extension.h", 95));
    return array;
}

void spIkConstraintDataArray_dispose(spIkConstraintDataArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spIkConstraintDataArray_clear(spIkConstraintDataArray* self) {
    self.size = 0;
}

spIkConstraintDataArray* spIkConstraintDataArray_setSize(spIkConstraintDataArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spIkConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spIkConstraintData*) * self.capacity)));
    }
    return self;
}

void spIkConstraintDataArray_ensureCapacity(spIkConstraintDataArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spIkConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spIkConstraintData*) * self.capacity)));
}

void spIkConstraintDataArray_add(spIkConstraintDataArray* self, spIkConstraintData* value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spIkConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spIkConstraintData*) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spIkConstraintDataArray_addAll(spIkConstraintDataArray* self, spIkConstraintDataArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spIkConstraintDataArray_add(self, other.items[i]);
    }
}

void spIkConstraintDataArray_addAllValues(spIkConstraintDataArray* self, spIkConstraintData** values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spIkConstraintDataArray_add(self, values[i]);
    }
}

void spIkConstraintDataArray_removeAt(spIkConstraintDataArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spIkConstraintData*) * (self.size - index)));
}

i32 spIkConstraintDataArray_contains(spIkConstraintDataArray* self, spIkConstraintData* value) {
    spIkConstraintData** items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spIkConstraintData* spIkConstraintDataArray_pop(spIkConstraintDataArray* self) {
    spIkConstraintData* item = self.items[--self.size];
    return item;
}

spIkConstraintData* spIkConstraintDataArray_peek(spIkConstraintDataArray* self) {
    return self.items[self.size - 1];
}

spTransformConstraintDataArray* spTransformConstraintDataArray_create(i32 initialCapacity) {
    var array = cast(spTransformConstraintDataArray*, _spCalloc(1, cast(u64, sizeof(spTransformConstraintDataArray)), "extension.h", 95));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spTransformConstraintData**, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spTransformConstraintData*)), "extension.h", 95));
    return array;
}

void spTransformConstraintDataArray_dispose(spTransformConstraintDataArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spTransformConstraintDataArray_clear(spTransformConstraintDataArray* self) {
    self.size = 0;
}

spTransformConstraintDataArray* spTransformConstraintDataArray_setSize(spTransformConstraintDataArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spTransformConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spTransformConstraintData*) * self.capacity)));
    }
    return self;
}

void spTransformConstraintDataArray_ensureCapacity(spTransformConstraintDataArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spTransformConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spTransformConstraintData*) * self.capacity)));
}

void spTransformConstraintDataArray_add(spTransformConstraintDataArray* self, spTransformConstraintData* value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spTransformConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spTransformConstraintData*) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spTransformConstraintDataArray_addAll(spTransformConstraintDataArray* self, spTransformConstraintDataArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spTransformConstraintDataArray_add(self, other.items[i]);
    }
}

void spTransformConstraintDataArray_addAllValues(spTransformConstraintDataArray* self, spTransformConstraintData** values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spTransformConstraintDataArray_add(self, values[i]);
    }
}

void spTransformConstraintDataArray_removeAt(spTransformConstraintDataArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spTransformConstraintData*) * (self.size - index)));
}

i32 spTransformConstraintDataArray_contains(spTransformConstraintDataArray* self, spTransformConstraintData* value) {
    spTransformConstraintData** items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spTransformConstraintData* spTransformConstraintDataArray_pop(spTransformConstraintDataArray* self) {
    spTransformConstraintData* item = self.items[--self.size];
    return item;
}

spTransformConstraintData* spTransformConstraintDataArray_peek(spTransformConstraintDataArray* self) {
    return self.items[self.size - 1];
}

spPathConstraintDataArray* spPathConstraintDataArray_create(i32 initialCapacity) {
    var array = cast(spPathConstraintDataArray*, _spCalloc(1, cast(u64, sizeof(spPathConstraintDataArray)), "extension.h", 95));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spPathConstraintData**, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spPathConstraintData*)), "extension.h", 95));
    return array;
}

void spPathConstraintDataArray_dispose(spPathConstraintDataArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spPathConstraintDataArray_clear(spPathConstraintDataArray* self) {
    self.size = 0;
}

spPathConstraintDataArray* spPathConstraintDataArray_setSize(spPathConstraintDataArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spPathConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spPathConstraintData*) * self.capacity)));
    }
    return self;
}

void spPathConstraintDataArray_ensureCapacity(spPathConstraintDataArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spPathConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spPathConstraintData*) * self.capacity)));
}

void spPathConstraintDataArray_add(spPathConstraintDataArray* self, spPathConstraintData* value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spPathConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spPathConstraintData*) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spPathConstraintDataArray_addAll(spPathConstraintDataArray* self, spPathConstraintDataArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spPathConstraintDataArray_add(self, other.items[i]);
    }
}

void spPathConstraintDataArray_addAllValues(spPathConstraintDataArray* self, spPathConstraintData** values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spPathConstraintDataArray_add(self, values[i]);
    }
}

void spPathConstraintDataArray_removeAt(spPathConstraintDataArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spPathConstraintData*) * (self.size - index)));
}

i32 spPathConstraintDataArray_contains(spPathConstraintDataArray* self, spPathConstraintData* value) {
    spPathConstraintData** items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spPathConstraintData* spPathConstraintDataArray_pop(spPathConstraintDataArray* self) {
    spPathConstraintData* item = self.items[--self.size];
    return item;
}

spPathConstraintData* spPathConstraintDataArray_peek(spPathConstraintDataArray* self) {
    return self.items[self.size - 1];
}

spPhysicsConstraintDataArray* spPhysicsConstraintDataArray_create(i32 initialCapacity) {
    var array = cast(spPhysicsConstraintDataArray*, _spCalloc(1, cast(u64, sizeof(spPhysicsConstraintDataArray)), "extension.h", 95));
    array.size = 0;
    array.capacity = initialCapacity;
    array.items = cast(spPhysicsConstraintData**, _spCalloc(cast(u64, initialCapacity), cast(u64, sizeof(spPhysicsConstraintData*)), "extension.h", 95));
    return array;
}

void spPhysicsConstraintDataArray_dispose(spPhysicsConstraintDataArray* self) {
    _spFree(cast(void*, self.items));
    _spFree(cast(void*, self));
}

void spPhysicsConstraintDataArray_clear(spPhysicsConstraintDataArray* self) {
    self.size = 0;
}

spPhysicsConstraintDataArray* spPhysicsConstraintDataArray_setSize(spPhysicsConstraintDataArray* self, i32 newSize) {
    self.size = newSize;
    if self.capacity < newSize {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spPhysicsConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spPhysicsConstraintData*) * self.capacity)));
    }
    return self;
}

void spPhysicsConstraintDataArray_ensureCapacity(spPhysicsConstraintDataArray* self, i32 newCapacity) {
    if self.capacity >= newCapacity {
        return;
    }
    self.capacity = newCapacity;
    self.items = cast(spPhysicsConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spPhysicsConstraintData*) * self.capacity)));
}

void spPhysicsConstraintDataArray_add(spPhysicsConstraintDataArray* self, spPhysicsConstraintData* value) {
    if self.size == self.capacity {
        self.capacity = 8 > cast(i32, cast(f32, self.size) * 1.75f) ? 8 : cast(i32, cast(f32, self.size) * 1.75f);
        self.items = cast(spPhysicsConstraintData**, _spRealloc(self.items, cast(u64, sizeof(spPhysicsConstraintData*) * self.capacity)));
    }
    self.items[self.size++] = value;
}

void spPhysicsConstraintDataArray_addAll(spPhysicsConstraintDataArray* self, spPhysicsConstraintDataArray* other) {
    i32 i = 0;
    for ; i < other.size; i++ {
        spPhysicsConstraintDataArray_add(self, other.items[i]);
    }
}

void spPhysicsConstraintDataArray_addAllValues(spPhysicsConstraintDataArray* self, spPhysicsConstraintData** values, i32 offset, i32 count) {
    i32 i = offset;
    i32 n = offset + count;
    for ; i < n; i++ {
        spPhysicsConstraintDataArray_add(self, values[i]);
    }
}

void spPhysicsConstraintDataArray_removeAt(spPhysicsConstraintDataArray* self, i32 index) {
    self.size--;
    memmove(self.items + index, self.items + index + 1, cast(u64, sizeof(spPhysicsConstraintData*) * (self.size - index)));
}

i32 spPhysicsConstraintDataArray_contains(spPhysicsConstraintDataArray* self, spPhysicsConstraintData* value) {
    spPhysicsConstraintData** items = self.items;
    i32 i;
    i32 n;
    {
        i = 0;
        for n = self.size; i < n; i++ {
            if items[i] == value {
                return -1;
            }
        }
    }
    return 0;
}

spPhysicsConstraintData* spPhysicsConstraintDataArray_pop(spPhysicsConstraintDataArray* self) {
    spPhysicsConstraintData* item = self.items[--self.size];
    return item;
}

spPhysicsConstraintData* spPhysicsConstraintDataArray_peek(spPhysicsConstraintDataArray* self) {
    return self.items[self.size - 1];
}

_Entry* _Entry_create(i32 slotIndex, u8* name, spAttachment* attachment) {
    var self = cast(_Entry*, _spCalloc(1, cast(u64, sizeof(_Entry)), "extension.h", 95));
    self.slotIndex = slotIndex;
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 92));
    strcpy(self.name, name);
    self.attachment = attachment;
    return self;
}

void _Entry_dispose(_Entry* self) {
    spAttachment_dispose(self.attachment);
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self));
}

private {
_SkinHashTableEntry* _SkinHashTableEntry_create(_Entry* entry) {
    var self = cast(_SkinHashTableEntry*, _spCalloc(1, cast(u64, sizeof(_SkinHashTableEntry)), "extension.h", 95));
    self.entry = entry;
    return self;
}

void _SkinHashTableEntry_dispose(_SkinHashTableEntry* self) {
    _spFree(cast(void*, self));
}
}

/**/
spSkin* spSkin_create(u8* name) {
    spSkin* self = &cast(_spSkin*, _spCalloc(1, cast(u64, sizeof(_spSkin)), "extension.h", 95)).super;
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 92));
    strcpy(self.name, name);
    self.bones = spBoneDataArray_create(4);
    self.ikConstraints = spIkConstraintDataArray_create(4);
    self.transformConstraints = spTransformConstraintDataArray_create(4);
    self.pathConstraints = spPathConstraintDataArray_create(4);
    self.physicsConstraints = spPhysicsConstraintDataArray_create(4);
    spColor_setFromFloats(&self.color, 0.99607843f, 0.61960787f, 0.30980393f, 1.0f);
    return self;
}

void spSkin_dispose(spSkin* self) {
    _Entry* entry = cast(_spSkin*, self).entries;
    while entry != null {
        _Entry* nextEntry = entry.next;
        _Entry_dispose(entry);
        entry = nextEntry;
    }
    {
        _SkinHashTableEntry** currentHashtableEntry = cast(_spSkin*, self).entriesHashTable;
        i32 i;
        for i = 0; i < 100; ++i {
            _SkinHashTableEntry* hashtableEntry = *currentHashtableEntry;
            while hashtableEntry != null {
                _SkinHashTableEntry* nextEntry = hashtableEntry.next;
                _SkinHashTableEntry_dispose(hashtableEntry);
                hashtableEntry = nextEntry;
            }
            ++currentHashtableEntry;
        }
    }
    spBoneDataArray_dispose(self.bones);
    spIkConstraintDataArray_dispose(self.ikConstraints);
    spTransformConstraintDataArray_dispose(self.transformConstraints);
    spPathConstraintDataArray_dispose(self.pathConstraints);
    spPhysicsConstraintDataArray_dispose(self.physicsConstraints);
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self));
}

void spSkin_setAttachment(spSkin* self, i32 slotIndex, u8* name, spAttachment* attachment) {
    _SkinHashTableEntry* existingEntry = null;
    _SkinHashTableEntry* hashEntry = cast(_spSkin*, self).entriesHashTable[cast(u32, slotIndex) % 100];
    while hashEntry != null {
        if hashEntry.entry.slotIndex == slotIndex && strcmp(hashEntry.entry.name, name) == 0 {
            existingEntry = hashEntry;
            break;
        }
        hashEntry = hashEntry.next;
    }
    if attachment != null {
        attachment.refCount++;
    }
    if existingEntry != null {
        if hashEntry.entry.attachment != null {
            spAttachment_dispose(hashEntry.entry.attachment);
        }
        hashEntry.entry.attachment = attachment;
    } else {
        _Entry* newEntry = _Entry_create(slotIndex, name, attachment);
        newEntry.next = cast(_spSkin*, self).entries;
        cast(_spSkin*, self).entries = newEntry;
        {
            u32 hashTableIndex = cast(u32, slotIndex) % 100;
            _SkinHashTableEntry** hashTable = cast(_spSkin*, self).entriesHashTable;
            _SkinHashTableEntry* newHashEntry = _SkinHashTableEntry_create(newEntry);
            newHashEntry.next = hashTable[hashTableIndex];
            cast(_spSkin*, self).entriesHashTable[hashTableIndex] = newHashEntry;
        }
    }
}

spAttachment* spSkin_getAttachment(spSkin* self, i32 slotIndex, u8* name) {
    _SkinHashTableEntry* hashEntry = cast(_spSkin*, self).entriesHashTable[cast(u32, slotIndex) % 100];
    while hashEntry != null {
        if hashEntry.entry.slotIndex == slotIndex && strcmp(hashEntry.entry.name, name) == 0 {
            return hashEntry.entry.attachment;
        }
        hashEntry = hashEntry.next;
    }
    return null;
}

u8* spSkin_getAttachmentName(spSkin* self, i32 slotIndex, i32 attachmentIndex) {
    _Entry* entry = cast(_spSkin*, self).entries;
    i32 i = 0;
    while entry != null {
        if entry.slotIndex == slotIndex {
            if i == attachmentIndex {
                return entry.name;
            }
            i++;
        }
        entry = entry.next;
    }
    return null;
}

void spSkin_attachAll(spSkin* self, spSkeleton* skeleton, spSkin* oldSkin) {
    _Entry* entry = cast(_spSkin*, oldSkin).entries;
    while entry != null {
        spSlot* slot = skeleton.slots[entry.slotIndex];
        if slot.attachment == entry.attachment {
            spAttachment* attachment = spSkin_getAttachment(self, entry.slotIndex, entry.name);
            if attachment != null {
                spSlot_setAttachment(slot, attachment);
            }
        }
        entry = entry.next;
    }
}

void spSkin_addSkin(spSkin* self, spSkin* other) {
    i32 i = 0;
    spSkinEntry* entry;
    for i = 0; i < other.bones.size; i++ {
        if spBoneDataArray_contains(self.bones, other.bones.items[i]) == 0 {
            spBoneDataArray_add(self.bones, other.bones.items[i]);
        }
    }
    for i = 0; i < other.ikConstraints.size; i++ {
        if spIkConstraintDataArray_contains(self.ikConstraints, other.ikConstraints.items[i]) == 0 {
            spIkConstraintDataArray_add(self.ikConstraints, other.ikConstraints.items[i]);
        }
    }
    for i = 0; i < other.transformConstraints.size; i++ {
        if spTransformConstraintDataArray_contains(self.transformConstraints, other.transformConstraints.items[i]) == 0 {
            spTransformConstraintDataArray_add(self.transformConstraints, other.transformConstraints.items[i]);
        }
    }
    for i = 0; i < other.pathConstraints.size; i++ {
        if spPathConstraintDataArray_contains(self.pathConstraints, other.pathConstraints.items[i]) == 0 {
            spPathConstraintDataArray_add(self.pathConstraints, other.pathConstraints.items[i]);
        }
    }
    for i = 0; i < other.physicsConstraints.size; i++ {
        if spPhysicsConstraintDataArray_contains(self.physicsConstraints, other.physicsConstraints.items[i]) == 0 {
            spPhysicsConstraintDataArray_add(self.physicsConstraints, other.physicsConstraints.items[i]);
        }
    }
    entry = spSkin_getAttachments(other);
    while entry != null {
        spSkin_setAttachment(self, entry.slotIndex, entry.name, entry.attachment);
        entry = entry.next;
    }
}

void spSkin_copySkin(spSkin* self, spSkin* other) {
    i32 i = 0;
    spSkinEntry* entry;
    for i = 0; i < other.bones.size; i++ {
        if spBoneDataArray_contains(self.bones, other.bones.items[i]) == 0 {
            spBoneDataArray_add(self.bones, other.bones.items[i]);
        }
    }
    for i = 0; i < other.ikConstraints.size; i++ {
        if spIkConstraintDataArray_contains(self.ikConstraints, other.ikConstraints.items[i]) == 0 {
            spIkConstraintDataArray_add(self.ikConstraints, other.ikConstraints.items[i]);
        }
    }
    for i = 0; i < other.transformConstraints.size; i++ {
        if spTransformConstraintDataArray_contains(self.transformConstraints, other.transformConstraints.items[i]) == 0 {
            spTransformConstraintDataArray_add(self.transformConstraints, other.transformConstraints.items[i]);
        }
    }
    for i = 0; i < other.pathConstraints.size; i++ {
        if spPathConstraintDataArray_contains(self.pathConstraints, other.pathConstraints.items[i]) == 0 {
            spPathConstraintDataArray_add(self.pathConstraints, other.pathConstraints.items[i]);
        }
    }
    for i = 0; i < other.physicsConstraints.size; i++ {
        if spPhysicsConstraintDataArray_contains(self.physicsConstraints, other.physicsConstraints.items[i]) == 0 {
            spPhysicsConstraintDataArray_add(self.physicsConstraints, other.physicsConstraints.items[i]);
        }
    }
    entry = spSkin_getAttachments(other);
    while entry != null {
        if entry.attachment.type == SP_ATTACHMENT_MESH {
            spMeshAttachment* attachment = spMeshAttachment_newLinkedMesh(cast(spMeshAttachment*, entry.attachment));
            spSkin_setAttachment(self, entry.slotIndex, entry.name, &attachment.super.super);
        } else {
            spAttachment* attachment = entry.attachment != null ? spAttachment_copy(entry.attachment) : null;
            spSkin_setAttachment(self, entry.slotIndex, entry.name, attachment);
        }
        entry = entry.next;
    }
}

spSkinEntry* spSkin_getAttachments(spSkin* self) {
    return cast(_spSkin*, self).entries;
}

void spSkin_clear(spSkin* self) {
    _Entry* entry = cast(_spSkin*, self).entries;
    while entry != null {
        _Entry* nextEntry = entry.next;
        _Entry_dispose(entry);
        entry = nextEntry;
    }
    cast(_spSkin*, self).entries = null;
    {
        _SkinHashTableEntry** currentHashtableEntry = cast(_spSkin*, self).entriesHashTable;
        i32 i;
        for i = 0; i < 100; ++i {
            _SkinHashTableEntry* hashtableEntry = *currentHashtableEntry;
            while hashtableEntry != null {
                _SkinHashTableEntry* nextEntry = hashtableEntry.next;
                _SkinHashTableEntry_dispose(hashtableEntry);
                hashtableEntry = nextEntry;
            }
            cast(_spSkin*, self).entriesHashTable[i] = null;
            ++currentHashtableEntry;
        }
    }
    spBoneDataArray_clear(self.bones);
    spIkConstraintDataArray_clear(self.ikConstraints);
    spTransformConstraintDataArray_clear(self.transformConstraints);
    spPathConstraintDataArray_clear(self.pathConstraints);
    spPhysicsConstraintDataArray_clear(self.physicsConstraints);
}

spSlot* spSlot_create(spSlotData* data, spBone* bone) {
    var self = cast(spSlot*, _spCalloc(1, cast(u64, sizeof(spSlot)), "extension.h", 87));
    self.data = data;
    self.bone = bone;
    spColor_setFromFloats(&self.color, 1.0f, 1.0f, 1.0f, 1.0f);
    self.darkColor = data.darkColor == null ? null : spColor_create();
    spSlot_setToSetupPose(self);
    return self;
}

void spSlot_dispose(spSlot* self) {
    _spFree(cast(void*, self.deform));
    _spFree(cast(void*, self.darkColor));
    _spFree(cast(void*, self));
}

private {
i32 isVertexAttachment(spAttachment* attachment) {
    if attachment == null {
        return 0;
    }
    switch attachment.type {
        case SP_ATTACHMENT_BOUNDING_BOX, SP_ATTACHMENT_CLIPPING, SP_ATTACHMENT_MESH, SP_ATTACHMENT_PATH: {
            return -1;
        }
        default: {
            return 0;
        }
    }
}
}

void spSlot_setAttachment(spSlot* self, spAttachment* attachment) {
    if attachment == self.attachment {
        return;
    }
    if !isVertexAttachment(attachment) || !isVertexAttachment(self.attachment) || cast(spVertexAttachment*, attachment).timelineAttachment != cast(spVertexAttachment*, self.attachment).timelineAttachment {
        self.deformCount = 0;
    }
    self.attachment = attachment;
    self.sequenceIndex = -1;
}

void spSlot_setToSetupPose(spSlot* self) {
    spColor_setFromColor(&self.color, &self.data.color);
    if self.darkColor != null {
        spColor_setFromColor(self.darkColor, self.data.darkColor);
    }
    if self.data.attachmentName == null {
        spSlot_setAttachment(self, null);
    } else {
        spAttachment* attachment = spSkeleton_getAttachmentForSlotIndex(self.bone.skeleton, self.data.index, self.data.attachmentName);
        self.attachment = null;
        spSlot_setAttachment(self, attachment);
    }
}

spSlotData* spSlotData_create(i32 index, u8* name, spBoneData* boneData) {
    var self = cast(spSlotData*, _spCalloc(1, cast(u64, sizeof(spSlotData)), "extension.h", 57));
    self.index = index;
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 57));
    strcpy(self.name, name);
    self.boneData = boneData;
    spColor_setFromFloats(&self.color, 1.0f, 1.0f, 1.0f, 1.0f);
    self.visible = -1;
    return self;
}

void spSlotData_dispose(spSlotData* self) {
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self.attachmentName));
    _spFree(cast(void*, self.darkColor));
    _spFree(cast(void*, self));
}

void spSlotData_setAttachmentName(spSlotData* self, u8* attachmentName) {
    _spFree(cast(void*, self.attachmentName));
    if attachmentName != null {
        self.attachmentName = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(attachmentName) + 1), "extension.h", 57));
        strcpy(self.attachmentName, attachmentName);
    } else {
        self.attachmentName = null;
    }
}

spTransformConstraint* spTransformConstraint_create(spTransformConstraintData* data, spSkeleton* skeleton) {
    i32 i;
    var self = cast(spTransformConstraint*, _spCalloc(1, cast(u64, sizeof(spTransformConstraint)), "extension.h", 78));
    self.data = data;
    self.mixRotate = data.mixRotate;
    self.mixX = data.mixX;
    self.mixY = data.mixY;
    self.mixScaleX = data.mixScaleX;
    self.mixScaleY = data.mixScaleY;
    self.mixShearY = data.mixShearY;
    self.bonesCount = data.bonesCount;
    self.bones = cast(spBone**, _spMalloc(cast(u64, sizeof(spBone*) * self.bonesCount), "extension.h", 74));
    for i = 0; i < self.bonesCount; ++i {
        self.bones[i] = spSkeleton_findBone(skeleton, self.data.bones[i].name);
    }
    self.target = spSkeleton_findBone(skeleton, self.data.target.name);
    return self;
}

void spTransformConstraint_dispose(spTransformConstraint* self) {
    _spFree(cast(void*, self.bones));
    _spFree(cast(void*, self));
}

void _spTransformConstraint_applyAbsoluteWorld(spTransformConstraint* self) {
    f32 mixRotate = self.mixRotate;
    f32 mixX = self.mixX;
    f32 mixY = self.mixY;
    f32 mixScaleX = self.mixScaleX;
    f32 mixScaleY = self.mixScaleY;
    f32 mixShearY = self.mixShearY;
    i32 translate = mixX != 0.0f || mixY != 0.0f;
    spBone* target = self.target;
    f32 ta = target.a;
    f32 tb = target.b;
    f32 tc = target.c;
    f32 td = target.d;
    f32 degRadReflect = ta * td - tb * tc > 0.0f ? 3.141592653589793f / 180.0f : -(3.141592653589793f / 180.0f);
    f32 offsetRotation = self.data.offsetRotation * degRadReflect;
    f32 offsetShearY = self.data.offsetShearY * degRadReflect;
    i32 i;
    f32 a;
    f32 b;
    f32 c;
    f32 d;
    f32 r;
    f32 cosine;
    f32 sine;
    f32 x;
    f32 y;
    f32 s;
    f32 by;
    for i = 0; i < self.bonesCount; ++i {
        spBone* bone = self.bones[i];
        if mixRotate != 0.0f {
            a = bone.a;
            b = bone.b;
            c = bone.c;
            d = bone.d;
            r = atan2f(tc, ta) - atan2f(c, a) + offsetRotation;
            if r > 3.141592653589793f {
                r -= 3.141592653589793f * 2.0f;
            } else if r < -3.141592653589793f {
                r += 3.141592653589793f * 2.0f;
            }
            r *= mixRotate;
            cosine = cosf(r);
            sine = sinf(r);
            bone.a = cosine * a - sine * c;
            bone.b = cosine * b - sine * d;
            bone.c = sine * a + cosine * c;
            bone.d = sine * b + cosine * d;
        }
        if translate != 0 {
            spBone_localToWorld(target, self.data.offsetX, self.data.offsetY, &x, &y);
            bone.worldX += (x - bone.worldX) * mixX;
            bone.worldY += (y - bone.worldY) * mixY;
        }
        if mixScaleX > 0.0f {
            s = sqrtf(bone.a * bone.a + bone.c * bone.c);
            if s != 0.0f {
                s = (s + (sqrtf(ta * ta + tc * tc) - s + self.data.offsetScaleX) * mixScaleX) / s;
            }
            bone.a *= s;
            bone.c *= s;
        }
        if mixScaleY != 0.0f {
            s = sqrtf(bone.b * bone.b + bone.d * bone.d);
            if s != 0.0f {
                s = (s + (sqrtf(tb * tb + td * td) - s + self.data.offsetScaleY) * mixScaleY) / s;
            }
            bone.b *= s;
            bone.d *= s;
        }
        if mixShearY > 0.0f {
            b = bone.b;
            d = bone.d;
            by = atan2f(d, b);
            r = atan2f(td, tb) - atan2f(tc, ta) - (by - atan2f(bone.c, bone.a));
            s = sqrtf(b * b + d * d);
            if r > 3.141592653589793f {
                r -= 3.141592653589793f * 2.0f;
            } else if r < -3.141592653589793f {
                r += 3.141592653589793f * 2.0f;
            }
            r = by + (r + offsetShearY) * mixShearY;
            bone.b = cosf(r) * s;
            bone.d = sinf(r) * s;
        }
        spBone_updateAppliedTransform(bone);
    }
}

void _spTransformConstraint_applyRelativeWorld(spTransformConstraint* self) {
    f32 mixRotate = self.mixRotate;
    f32 mixX = self.mixX;
    f32 mixY = self.mixY;
    f32 mixScaleX = self.mixScaleX;
    f32 mixScaleY = self.mixScaleY;
    f32 mixShearY = self.mixShearY;
    i32 translate = mixX != 0.0f || mixY != 0.0f;
    spBone* target = self.target;
    f32 ta = target.a;
    f32 tb = target.b;
    f32 tc = target.c;
    f32 td = target.d;
    f32 degRadReflect = ta * td - tb * tc > 0.0f ? 3.141592653589793f / 180.0f : -(3.141592653589793f / 180.0f);
    f32 offsetRotation = self.data.offsetRotation * degRadReflect;
    f32 offsetShearY = self.data.offsetShearY * degRadReflect;
    i32 i;
    f32 a;
    f32 b;
    f32 c;
    f32 d;
    f32 r;
    f32 cosine;
    f32 sine;
    f32 x;
    f32 y;
    f32 s;
    for i = 0; i < self.bonesCount; ++i {
        spBone* bone = self.bones[i];
        if mixRotate != 0.0f {
            a = bone.a;
            b = bone.b;
            c = bone.c;
            d = bone.d;
            r = atan2f(tc, ta) + offsetRotation;
            if r > 3.141592653589793f {
                r -= 3.141592653589793f * 2.0f;
            } else if r < -3.141592653589793f {
                r += 3.141592653589793f * 2.0f;
            }
            r *= mixRotate;
            cosine = cosf(r);
            sine = sinf(r);
            bone.a = cosine * a - sine * c;
            bone.b = cosine * b - sine * d;
            bone.c = sine * a + cosine * c;
            bone.d = sine * b + cosine * d;
        }
        if translate != 0 {
            spBone_localToWorld(target, self.data.offsetX, self.data.offsetY, &x, &y);
            bone.worldX += x * mixX;
            bone.worldY += y * mixY;
        }
        if mixScaleX != 0.0f {
            s = (sqrtf(ta * ta + tc * tc) - 1.0f + self.data.offsetScaleX) * mixScaleX + 1.0f;
            bone.a *= s;
            bone.c *= s;
        }
        if mixScaleY > 0.0f {
            s = (sqrtf(tb * tb + td * td) - 1.0f + self.data.offsetScaleY) * mixScaleY + 1.0f;
            bone.b *= s;
            bone.d *= s;
        }
        if mixShearY > 0.0f {
            r = atan2f(td, tb) - atan2f(tc, ta);
            if r > 3.141592653589793f {
                r -= 3.141592653589793f * 2.0f;
            } else if r < -3.141592653589793f {
                r += 3.141592653589793f * 2.0f;
            }
            b = bone.b;
            d = bone.d;
            r = atan2f(d, b) + (r - 3.141592653589793f / 2.0f + offsetShearY) * mixShearY;
            s = sqrtf(b * b + d * d);
            bone.b = cosf(r) * s;
            bone.d = sinf(r) * s;
        }
        spBone_updateAppliedTransform(bone);
    }
}

void _spTransformConstraint_applyAbsoluteLocal(spTransformConstraint* self) {
    f32 mixRotate = self.mixRotate;
    f32 mixX = self.mixX;
    f32 mixY = self.mixY;
    f32 mixScaleX = self.mixScaleX;
    f32 mixScaleY = self.mixScaleY;
    f32 mixShearY = self.mixShearY;
    spBone* target = self.target;
    i32 i;
    f32 rotation;
    f32 r;
    f32 x;
    f32 y;
    f32 scaleX;
    f32 scaleY;
    f32 shearY;
    for i = 0; i < self.bonesCount; ++i {
        spBone* bone = self.bones[i];
        rotation = bone.arotation;
        if mixRotate != 0.0f {
            r = target.arotation - rotation + self.data.offsetRotation;
            r -= cast(f32, ceil(r / 360.0f - 0.5)) * 360.0f;
            rotation += r * mixRotate;
        }
        x = bone.ax;
        y = bone.ay;
        x += (target.ax - x + self.data.offsetX) * mixX;
        y += (target.ay - y + self.data.offsetY) * mixY;
        scaleX = bone.ascaleX;
        scaleY = bone.ascaleY;
        if mixScaleX != 0.0f && scaleX != 0.0f {
            scaleX = (scaleX + (target.ascaleX - scaleX + self.data.offsetScaleX) * mixScaleX) / scaleX;
        }
        if mixScaleY != 0.0f && scaleY != 0.0f {
            scaleY = (scaleY + (target.ascaleY - scaleY + self.data.offsetScaleY) * mixScaleY) / scaleY;
        }
        shearY = bone.ashearY;
        if mixShearY != 0.0f {
            r = target.ashearY - shearY + self.data.offsetShearY;
            r -= cast(f32, ceil(r / 360.0f - 0.5)) * 360.0f;
            shearY += r * mixShearY;
        }
        spBone_updateWorldTransformWith(bone, x, y, rotation, scaleX, scaleY, bone.ashearX, shearY);
    }
}

void _spTransformConstraint_applyRelativeLocal(spTransformConstraint* self) {
    f32 mixRotate = self.mixRotate;
    f32 mixX = self.mixX;
    f32 mixY = self.mixY;
    f32 mixScaleX = self.mixScaleX;
    f32 mixScaleY = self.mixScaleY;
    f32 mixShearY = self.mixShearY;
    spBone* target = self.target;
    i32 i;
    f32 rotation;
    f32 x;
    f32 y;
    f32 scaleX;
    f32 scaleY;
    f32 shearY;
    for i = 0; i < self.bonesCount; ++i {
        spBone* bone = self.bones[i];
        rotation = bone.arotation + (target.arotation + self.data.offsetRotation) * mixRotate;
        x = bone.ax + (target.ax + self.data.offsetX) * mixX;
        y = bone.ay + (target.ay + self.data.offsetY) * mixY;
        scaleX = bone.ascaleX * ((target.ascaleX - 1.0f + self.data.offsetScaleX) * mixScaleX + 1.0f);
        scaleY = bone.ascaleY * ((target.ascaleY - 1.0f + self.data.offsetScaleY) * mixScaleY + 1.0f);
        shearY = bone.ashearY + (target.ashearY + self.data.offsetShearY) * mixShearY;
        spBone_updateWorldTransformWith(bone, x, y, rotation, scaleX, scaleY, bone.ashearX, shearY);
    }
}

void spTransformConstraint_update(spTransformConstraint* self) {
    if self.mixRotate == 0.0f && self.mixX == 0.0f && self.mixY == 0.0f && self.mixScaleX == 0.0f && self.mixScaleY == 0.0f && self.mixShearY == 0.0f {
        return;
    }
    if self.data.local != 0 {
        if self.data.relative != 0 {
            _spTransformConstraint_applyRelativeLocal(self);
        } else {
            _spTransformConstraint_applyAbsoluteLocal(self);
        }
    } else {
        if self.data.relative != 0 {
            _spTransformConstraint_applyRelativeWorld(self);
        } else {
            _spTransformConstraint_applyAbsoluteWorld(self);
        }
    }
}

void spTransformConstraint_setToSetupPose(spTransformConstraint* self) {
    spTransformConstraintData* data = self.data;
    self.mixRotate = data.mixRotate;
    self.mixX = data.mixX;
    self.mixY = data.mixY;
    self.mixScaleX = data.mixScaleX;
    self.mixScaleY = data.mixScaleY;
    self.mixShearY = data.mixShearY;
}

spTransformConstraintData* spTransformConstraintData_create(u8* name) {
    var self = cast(spTransformConstraintData*, _spCalloc(1, cast(u64, sizeof(spTransformConstraintData)), "extension.h", 44));
    self.name = cast(u8*, _spMalloc(cast(u64, sizeof(u8)) * (strlen(name) + 1), "extension.h", 44));
    strcpy(self.name, name);
    return self;
}

void spTransformConstraintData_dispose(spTransformConstraintData* self) {
    _spFree(cast(void*, self.name));
    _spFree(cast(void*, self.bones));
    _spFree(cast(void*, self));
}

spTriangulator* spTriangulator_create() {
    var triangulator = cast(spTriangulator*, _spCalloc(1, cast(u64, sizeof(spTriangulator)), "extension.h", 88));
    triangulator.convexPolygons = spArrayFloatArray_create(16);
    triangulator.convexPolygonsIndices = spArrayShortArray_create(16);
    triangulator.indicesArray = spShortArray_create(128);
    triangulator.isConcaveArray = spIntArray_create(128);
    triangulator.triangles = spShortArray_create(128);
    triangulator.polygonPool = spArrayFloatArray_create(16);
    triangulator.polygonIndicesPool = spArrayShortArray_create(128);
    return triangulator;
}

void spTriangulator_dispose(spTriangulator* self) {
    i32 i;
    for i = 0; i < self.convexPolygons.size; i++ {
        spFloatArray_dispose(self.convexPolygons.items[i]);
    }
    spArrayFloatArray_dispose(self.convexPolygons);
    for i = 0; i < self.convexPolygonsIndices.size; i++ {
        spShortArray_dispose(self.convexPolygonsIndices.items[i]);
    }
    spArrayShortArray_dispose(self.convexPolygonsIndices);
    spShortArray_dispose(self.indicesArray);
    spIntArray_dispose(self.isConcaveArray);
    spShortArray_dispose(self.triangles);
    for i = 0; i < self.polygonPool.size; i++ {
        spFloatArray_dispose(self.polygonPool.items[i]);
    }
    spArrayFloatArray_dispose(self.polygonPool);
    for i = 0; i < self.polygonIndicesPool.size; i++ {
        spShortArray_dispose(self.polygonIndicesPool.items[i]);
    }
    spArrayShortArray_dispose(self.polygonIndicesPool);
    _spFree(cast(void*, self));
}

private {
spFloatArray* _obtainPolygon(spTriangulator* self) {
    if self.polygonPool.size == 0 {
        return spFloatArray_create(16);
    } else {
        return spArrayFloatArray_pop(self.polygonPool);
    }
}

void _freePolygon(spTriangulator* self, spFloatArray* polygon) {
    spArrayFloatArray_add(self.polygonPool, polygon);
}

void _freeAllPolygons(spTriangulator* self, spArrayFloatArray* polygons) {
    i32 i;
    for i = 0; i < polygons.size; i++ {
        _freePolygon(self, polygons.items[i]);
    }
}

spShortArray* _obtainPolygonIndices(spTriangulator* self) {
    if self.polygonIndicesPool.size == 0 {
        return spShortArray_create(16);
    } else {
        return spArrayShortArray_pop(self.polygonIndicesPool);
    }
}

void _freePolygonIndices(spTriangulator* self, spShortArray* indices) {
    spArrayShortArray_add(self.polygonIndicesPool, indices);
}

void _freeAllPolygonIndices(spTriangulator* self, spArrayShortArray* polygonIndices) {
    i32 i;
    for i = 0; i < polygonIndices.size; i++ {
        _freePolygonIndices(self, polygonIndices.items[i]);
    }
}

i32 _positiveArea(f32 p1x, f32 p1y, f32 p2x, f32 p2y, f32 p3x, f32 p3y) {
    return p1x * (p3y - p2y) + p2x * (p1y - p3y) + p3x * (p2y - p1y) >= 0.0f;
}

i32 _isConcave(i32 index, i32 vertexCount, f32* vertices, i16* indices) {
    i32 previous = cast(i32, indices[(vertexCount + index - 1) % vertexCount]) << 1;
    i32 current = cast(i32, indices[index]) << 1;
    i32 next = cast(i32, indices[(index + 1) % vertexCount]) << 1;
    return !_positiveArea(vertices[previous], vertices[previous + 1], vertices[current], vertices[current + 1], vertices[next], vertices[next + 1]);
}

i32 _winding(f32 p1x, f32 p1y, f32 p2x, f32 p2y, f32 p3x, f32 p3y) {
    f32 px = p2x - p1x;
    f32 py = p2y - p1y;
    return p3x * py - p3y * px + px * p1y - p1x * py >= 0.0f ? 1 : -1;
}
}

spShortArray* spTriangulator_triangulate(spTriangulator* self, spFloatArray* verticesArray) {
    f32* vertices = verticesArray.items;
    i32 vertexCount = verticesArray.size >> 1;
    i32 i;
    i32 n;
    i32 ii;
    spShortArray* indicesArray = self.indicesArray;
    i16* indices;
    spIntArray* isConcaveArray;
    i32* isConcave;
    spShortArray* triangles;
    spShortArray_clear(indicesArray);
    indices = spShortArray_setSize(indicesArray, vertexCount).items;
    for i = 0; i < vertexCount; i++ {
        indices[i] = cast(i16, i);
    }
    isConcaveArray = self.isConcaveArray;
    isConcave = spIntArray_setSize(isConcaveArray, vertexCount).items;
    {
        i = 0;
        for n = vertexCount; i < n; ++i {
            isConcave[i] = _isConcave(i, vertexCount, vertices, indices);
        }
    }
    triangles = self.triangles;
    spShortArray_clear(triangles);
    spShortArray_ensureCapacity(triangles, (0 > vertexCount - 2 ? 0 : vertexCount - 2) << 2);
    while vertexCount > 3 {
        i32 previous = vertexCount - 1;
        i32 next = 1;
        i32 previousIndex;
        i32 nextIndex;
        i = 0;
        while 1 != 0 {
            if isConcave[i] == 0 {
                i32 p1 = cast(i32, indices[previous]) << 1;
                i32 p2 = cast(i32, indices[i]) << 1;
                i32 p3 = cast(i32, indices[next]) << 1;
                f32 p1x = vertices[p1];
                f32 p1y = vertices[p1 + 1];
                f32 p2x = vertices[p2];
                f32 p2y = vertices[p2 + 1];
                f32 p3x = vertices[p3];
                f32 p3y = vertices[p3 + 1];
                for ii = (next + 1) % vertexCount; ii != previous; ii = (ii + 1) % vertexCount {
                    i32 v;
                    f32 vx;
                    f32 vy;
                    if isConcave[ii] == 0 {
                        continue;
                    }
                    v = cast(i32, indices[ii]) << 1;
                    vx = vertices[v];
                    vy = vertices[v + 1];
                    if _positiveArea(p3x, p3y, p1x, p1y, vx, vy) != 0 {
                        if _positiveArea(p1x, p1y, p2x, p2y, vx, vy) != 0 {
                            if _positiveArea(p2x, p2y, p3x, p3y, vx, vy) != 0 {
                                // TODO transminc: goto break_outer
                            }
                        }
                    }
                }
                break;
            }
            // TODO transminc: label break_outer:
            if next == 0 {
                while true {
                    if isConcave[i] == 0 {
                        break;
                    }
                    i--;
                    if !(i > 0) { break; }
                }
                break;
            }
            previous = i;
            i = next;
            next = (next + 1) % vertexCount;
        }
        spShortArray_add(triangles, indices[(vertexCount + i - 1) % vertexCount]);
        spShortArray_add(triangles, indices[i]);
        spShortArray_add(triangles, indices[(i + 1) % vertexCount]);
        spShortArray_removeAt(indicesArray, i);
        spIntArray_removeAt(isConcaveArray, i);
        vertexCount--;
        previousIndex = (vertexCount + i - 1) % vertexCount;
        nextIndex = i == vertexCount ? 0 : i;
        isConcave[previousIndex] = _isConcave(previousIndex, vertexCount, vertices, indices);
        isConcave[nextIndex] = _isConcave(nextIndex, vertexCount, vertices, indices);
    }
    if vertexCount == 3 {
        spShortArray_add(triangles, indices[2]);
        spShortArray_add(triangles, indices[0]);
        spShortArray_add(triangles, indices[1]);
    }
    return triangles;
}

spArrayFloatArray* spTriangulator_decompose(spTriangulator* self, spFloatArray* verticesArray, spShortArray* triangles) {
    f32* vertices = verticesArray.items;
    spArrayFloatArray* convexPolygons = self.convexPolygons;
    spArrayShortArray* convexPolygonsIndices;
    spShortArray* polygonIndices;
    spFloatArray* polygon;
    i32 fanBaseIndex;
    i32 lastWinding;
    i16* trianglesItems;
    i32 i;
    i32 n;
    _freeAllPolygons(self, convexPolygons);
    spArrayFloatArray_clear(convexPolygons);
    convexPolygonsIndices = self.convexPolygonsIndices;
    _freeAllPolygonIndices(self, convexPolygonsIndices);
    spArrayShortArray_clear(convexPolygonsIndices);
    polygonIndices = _obtainPolygonIndices(self);
    spShortArray_clear(polygonIndices);
    polygon = _obtainPolygon(self);
    spFloatArray_clear(polygon);
    fanBaseIndex = -1;
    lastWinding = 0;
    trianglesItems = triangles.items;
    {
        i = 0;
        for n = triangles.size; i < n; i += 3 {
            i32 t1 = cast(i32, trianglesItems[i]) << 1;
            i32 t2 = cast(i32, trianglesItems[i + 1]) << 1;
            i32 t3 = cast(i32, trianglesItems[i + 2]) << 1;
            f32 x1 = vertices[t1];
            f32 y1 = vertices[t1 + 1];
            f32 x2 = vertices[t2];
            f32 y2 = vertices[t2 + 1];
            f32 x3 = vertices[t3];
            f32 y3 = vertices[t3 + 1];
            i32 merged = 0;
            if fanBaseIndex == t1 {
                i32 o = polygon.size - 4;
                f32* p = polygon.items;
                i32 winding1 = _winding(p[o], p[o + 1], p[o + 2], p[o + 3], x3, y3);
                i32 winding2 = _winding(x3, y3, p[0], p[1], p[2], p[3]);
                if winding1 == lastWinding && winding2 == lastWinding {
                    spFloatArray_add(polygon, x3);
                    spFloatArray_add(polygon, y3);
                    spShortArray_add(polygonIndices, cast(i16, t3));
                    merged = 1;
                }
            }
            if merged == 0 {
                if polygon.size > 0 {
                    spArrayFloatArray_add(convexPolygons, polygon);
                    spArrayShortArray_add(convexPolygonsIndices, polygonIndices);
                } else {
                    _freePolygon(self, polygon);
                    _freePolygonIndices(self, polygonIndices);
                }
                polygon = _obtainPolygon(self);
                spFloatArray_clear(polygon);
                spFloatArray_add(polygon, x1);
                spFloatArray_add(polygon, y1);
                spFloatArray_add(polygon, x2);
                spFloatArray_add(polygon, y2);
                spFloatArray_add(polygon, x3);
                spFloatArray_add(polygon, y3);
                polygonIndices = _obtainPolygonIndices(self);
                spShortArray_clear(polygonIndices);
                spShortArray_add(polygonIndices, cast(i16, t1));
                spShortArray_add(polygonIndices, cast(i16, t2));
                spShortArray_add(polygonIndices, cast(i16, t3));
                lastWinding = _winding(x1, y1, x2, y2, x3, y3);
                fanBaseIndex = t1;
            }
        }
    }
    if polygon.size > 0 {
        spArrayFloatArray_add(convexPolygons, polygon);
        spArrayShortArray_add(convexPolygonsIndices, polygonIndices);
    }
    {
        i = 0;
        for n = convexPolygons.size; i < n; i++ {
            i32 firstIndex;
            i32 lastIndex;
            i32 o;
            f32* p;
            f32 prevPrevX;
            f32 prevPrevY;
            f32 prevX;
            f32 prevY;
            f32 firstX;
            f32 firstY;
            f32 secondX;
            f32 secondY;
            i32 winding;
            i32 ii;
            polygonIndices = convexPolygonsIndices.items[i];
            if polygonIndices.size == 0 {
                continue;
            }
            firstIndex = polygonIndices.items[0];
            lastIndex = polygonIndices.items[polygonIndices.size - 1];
            polygon = convexPolygons.items[i];
            o = polygon.size - 4;
            p = polygon.items;
            prevPrevX = p[o];
            prevPrevY = p[o + 1];
            prevX = p[o + 2];
            prevY = p[o + 3];
            firstX = p[0];
            firstY = p[1];
            secondX = p[2];
            secondY = p[3];
            winding = _winding(prevPrevX, prevPrevY, prevX, prevY, firstX, firstY);
            for ii = 0; ii < n; ii++ {
                spShortArray* otherIndices;
                i32 otherFirstIndex;
                i32 otherSecondIndex;
                i32 otherLastIndex;
                spFloatArray* otherPoly;
                f32 x3;
                f32 y3;
                i32 winding1;
                i32 winding2;
                if ii == i {
                    continue;
                }
                otherIndices = convexPolygonsIndices.items[ii];
                if otherIndices.size != 3 {
                    continue;
                }
                otherFirstIndex = otherIndices.items[0];
                otherSecondIndex = otherIndices.items[1];
                otherLastIndex = otherIndices.items[2];
                otherPoly = convexPolygons.items[ii];
                x3 = otherPoly.items[otherPoly.size - 2];
                y3 = otherPoly.items[otherPoly.size - 1];
                if otherFirstIndex != firstIndex || otherSecondIndex != lastIndex {
                    continue;
                }
                winding1 = _winding(prevPrevX, prevPrevY, prevX, prevY, x3, y3);
                winding2 = _winding(x3, y3, firstX, firstY, secondX, secondY);
                if winding1 == winding && winding2 == winding {
                    spFloatArray_clear(otherPoly);
                    spShortArray_clear(otherIndices);
                    spFloatArray_add(polygon, x3);
                    spFloatArray_add(polygon, y3);
                    spShortArray_add(polygonIndices, cast(i16, otherLastIndex));
                    prevPrevX = prevX;
                    prevPrevY = prevY;
                    prevX = x3;
                    prevY = y3;
                    ii = 0;
                }
            }
        }
    }
    for i = convexPolygons.size - 1; i >= 0; i-- {
        polygon = convexPolygons.items[i];
        if polygon.size == 0 {
            spArrayFloatArray_removeAt(convexPolygons, i);
            _freePolygon(self, polygon);
            polygonIndices = convexPolygonsIndices.items[i];
            spArrayShortArray_removeAt(convexPolygonsIndices, i);
            _freePolygonIndices(self, polygonIndices);
        }
    }
    return convexPolygons;
}
/* FIXME this is not thread-safe */
private { i32 nextID = 0; }

void _spVertexAttachment_init(spVertexAttachment* attachment) {
    attachment.id = nextID++;
    attachment.timelineAttachment = &attachment.super;
}

void _spVertexAttachment_deinit(spVertexAttachment* attachment) {
    _spAttachment_deinit(&attachment.super);
    _spFree(cast(void*, attachment.bones));
    _spFree(cast(void*, attachment.vertices));
}

void spVertexAttachment_computeWorldVertices(spVertexAttachment* self, spSlot* slot, i32 start, i32 count, f32* worldVertices, i32 offset, i32 stride) {
    spSkeleton* skeleton;
    i32 deformLength;
    f32* deformArray;
    f32* vertices;
    i32* bones;
    if self.super.type == SP_ATTACHMENT_MESH || self.super.type == SP_ATTACHMENT_LINKED_MESH {
        var mesh = cast(spMeshAttachment*, self);
        if mesh.sequence != null {
            spSequence_apply(mesh.sequence, slot, &self.super);
        }
    }
    count = offset + (count >> 1) * stride;
    skeleton = slot.bone.skeleton;
    deformLength = slot.deformCount;
    deformArray = slot.deform;
    vertices = self.vertices;
    bones = self.bones;
    if bones == null {
        spBone* bone;
        i32 v;
        i32 w;
        f32 x;
        f32 y;
        if deformLength > 0 {
            vertices = deformArray;
        }
        bone = slot.bone;
        x = bone.worldX;
        y = bone.worldY;
        {
            v = start;
            for w = offset; w < count; v += 2 {
                f32 vx = vertices[v];
                f32 vy = vertices[v + 1];
                worldVertices[w] = vx * bone.a + vy * bone.b + x;
                worldVertices[w + 1] = vx * bone.c + vy * bone.d + y;
                w += stride;
            }
        }
    } else {
        i32 v = 0;
        i32 skip = 0;
        i32 i;
        spBone** skeletonBones;
        for i = 0; i < start; i += 2 {
            i32 n = bones[v];
            v += n + 1;
            skip += n;
        }
        skeletonBones = skeleton.bones;
        if deformLength == 0 {
            i32 w;
            i32 b;
            {
                w = offset;
                for b = skip * 3; w < count; w += stride {
                    f32 wx = 0.0f;
                    f32 wy = 0.0f;
                    i32 n = bones[v++];
                    n += v;
                    for ; v < n; v++ {
                        spBone* bone = skeletonBones[bones[v]];
                        f32 vx = vertices[b];
                        f32 vy = vertices[b + 1];
                        f32 weight = vertices[b + 2];
                        wx += (vx * bone.a + vy * bone.b + bone.worldX) * weight;
                        wy += (vx * bone.c + vy * bone.d + bone.worldY) * weight;
                        b += 3;
                    }
                    worldVertices[w] = wx;
                    worldVertices[w + 1] = wy;
                }
            }
        } else {
            i32 w;
            i32 b;
            i32 f;
            {
                w = offset;
                b = skip * 3;
                for f = skip << 1; w < count; w += stride {
                    f32 wx = 0.0f;
                    f32 wy = 0.0f;
                    i32 n = bones[v++];
                    n += v;
                    for ; v < n; v++ {
                        spBone* bone = skeletonBones[bones[v]];
                        f32 vx = vertices[b] + deformArray[f];
                        f32 vy = vertices[b + 1] + deformArray[f + 1];
                        f32 weight = vertices[b + 2];
                        wx += (vx * bone.a + vy * bone.b + bone.worldX) * weight;
                        wy += (vx * bone.c + vy * bone.d + bone.worldY) * weight;
                        b += 3;
                        f += 2;
                    }
                    worldVertices[w] = wx;
                    worldVertices[w + 1] = wy;
                }
            }
        }
    }
}

void spVertexAttachment_copyTo(spVertexAttachment* from_var, spVertexAttachment* to) {
    if from_var.bonesCount != 0 {
        to.bonesCount = from_var.bonesCount;
        to.bones = cast(i32*, _spMalloc(cast(u64, sizeof(i32) * from_var.bonesCount), "extension.h", 90));
        memcpy(to.bones, from_var.bones, cast(u64, from_var.bonesCount * sizeof(i32)));
    } else {
        to.bonesCount = 0;
        if to.bones != null {
            _spFree(cast(void*, to.bones));
            to.bones = null;
        }
    }
    if from_var.verticesCount != 0 {
        to.verticesCount = from_var.verticesCount;
        to.vertices = cast(f32*, _spMalloc(cast(u64, sizeof(f32) * from_var.verticesCount), "extension.h", 90));
        memcpy(to.vertices, from_var.vertices, cast(u64, from_var.verticesCount * sizeof(f32)));
    } else {
        to.verticesCount = 0;
        if to.vertices != null {
            _spFree(cast(void*, to.vertices));
            to.vertices = null;
        }
    }
    to.worldVerticesLength = from_var.worldVerticesLength;
}

f32 _spInternalRandom() {
    return cast(f32, rand()) / cast(f32, RAND_MAX);
}
private {
fn(u64): void* mallocFunc = __tm_malloc;
fn(void*, u64): void* reallocFunc = __tm_realloc;
fn(u64, u8*, i32): void* debugMallocFunc = null;
fn(void*): void freeFunc = __tm_free;
fn(): f32 randomFunc = _spInternalRandom;
}

void* _spMalloc(u64 size, u8* file, i32 line) {
    if debugMallocFunc != null {
        return debugMallocFunc(size, file, line);
    }
    return mallocFunc(size);
}

void* _spCalloc(u64 num, u64 size, u8* file, i32 line) {
    void* ptr = _spMalloc(num * size, file, line);
    if ptr != null {
        memset(ptr, 0, num * size);
    }
    return ptr;
}

void* _spRealloc(void* ptr, u64 size) {
    return reallocFunc(ptr, size);
}

void _spFree(void* ptr) {
    freeFunc(ptr);
}

f32 _spRandom() {
    return cast(f32, randomFunc());
}

void _spSetDebugMalloc(fn(u64, u8*, i32): void* malloc) {
    debugMallocFunc = malloc;
}

void _spSetMalloc(fn(u64): void* malloc) {
    mallocFunc = malloc;
}

void _spSetRealloc(fn(void*, u64): void* realloc_var) {
    reallocFunc = realloc_var;
}

void _spSetFree(fn(void*): void free_var) {
    freeFunc = free_var;
}

void _spSetRandom(fn(): f32 random) {
    randomFunc = random;
}

u8* _spReadFile(u8* path, i32* length) {
    u8* data;
    u64 result;
    void* file = fopen(path, "rb");
    if file == null {
        return null;
    }
    fseek(file, 0, SEEK_END);
    *length = cast(i32, ftell(file));
    fseek(file, 0, SEEK_SET);
    data = cast(u8*, _spMalloc(cast(u64, sizeof(u8) * *length), "extension.h", 114));
    result = fread(data, cast(u64, 1), cast(u64, *length), file);
    ignore result;
    fclose(file);
    return data;
}

f32 _spMath_random(f32 min, f32 max) {
    return min + (max - min) * _spRandom();
}

f32 _spMath_randomTriangular(f32 min, f32 max) {
    return _spMath_randomTriangularWith(min, max, (min + max) * 0.5f);
}

f32 _spMath_randomTriangularWith(f32 min, f32 max, f32 mode) {
    f32 u = _spRandom();
    f32 d = max - min;
    if u <= (mode - min) / d {
        return min + sqrtf(u * d * (mode - min));
    }
    return max - sqrtf((1.0f - u) * d * (max - mode));
}

f32 _spMath_interpolate(fn(f32): f32 apply, f32 start, f32 end, f32 a) {
    return start + (end - start) * cast(f32, apply(a));
}

f32 _spMath_pow2_apply(f32 a) {
    if a <= 0.5 {
        return cast(f32, pow(a * 2.0f, 2.0) / 2.0);
    }
    return cast(f32, pow((a - 1.0f) * 2.0f, 2.0) / -2.0 + 1.0);
}

f32 _spMath_pow2out_apply(f32 a) {
    return cast(f32, pow(a - 1.0f, 2.0) * -1.0 + 1.0);
}

// spine-c support shims. The sapp concat gets its libc surface from
// lib/ext_libc.mc (via `import sokol_all;`), which lacks a few
// symbols spine-c needs; they live here instead of cstdlib_shim.mc
// (concatenating that would duplicate ext_libc's definitions).

// libc surface ext_libc lacks: rand (PhysicsConstraint jitter) and
// the FILE api (extension.c's default _spReadFile, dead code in the
// samples, data arrives via sokol_fetch, but it must compile).
// Extern shapes match ext/cstdlib_shim.mc exactly (program-wide
// extern signature law). Samples are windows-only today.
when os(windows) {
    extern "msvcrt.dll" {
        i32 rand();
        @must_use void* fopen(u8* path, u8* mode);
        i32 fclose(void* file);
        u64 fread(void* p, u64 sz, u64 n, void* f);
        i32 fseek(void* f, i64 off, i32 whence);
        i64 ftell(void* f);
    }
}

// wasm: no msvcrt and no local filesystem. spine's _spReadFile is
// unreachable in these samples; the atlas/skeleton bytes arrive over
// sokol_fetch and are parsed from memory, so the file entry points are
// stubs that make it fail cleanly rather than pretend. rand and strtol
// are real; spine's parsers use them.
when os(wasm) {
    void* fopen(u8* path, u8* mode) { ignore path; ignore mode; return null; }
    i32 fseek(void* f, i64 off, i32 whence) { ignore f; ignore off; ignore whence; return -1; }
    i64 ftell(void* f) { ignore f; return 0; }
    i32 fclose(void* f) { ignore f; return 0; }
    u64 fread(void* p, u64 sz, u64 n, void* f) {
        ignore p; ignore sz; ignore n; ignore f;
        return cast(u64, 0);
    }

}

// rand and strtol are pure minc and wanted by spine's parsers on every
// target msvcrt does not cover. The file entry points above stay
// wasm-only: on linux/macos sokol_fetch_post.mc's POSIX arm already
// defines them, and every spine sample pre_shims it ahead of this file.
when !os(windows) {
    // xorshift32, masked to RAND_MAX; spine only wants a cheap sequence
    u32 g_tm_rand_state = 305419896;
    i32 rand() {
        u32 x = g_tm_rand_state;
        x = x ^ (x << 13);
        x = x ^ (x >> 17);
        x = x ^ (x << 5);
        g_tm_rand_state = x;
        return cast(i32, x & 32767);
    }

}

// strtol stays wasm-only: on linux and macos ext_libc binds libc's,
// and a second definition collides with it.
when os(wasm) {
    i64 strtol(u8* s, u8** endptr, i32 base) {
        u8* p = s;
        while *p == 32 || (*p >= 9 && *p <= 13) { p = p + 1; }
        i64 sign = 1;
        if *p == 43 { p = p + 1; }
        else if *p == 45 { sign = 0 - 1; p = p + 1; }
        // base 0 means decimal here, not C's 0x/0-prefix detection
        i64 b = cast(i64, base);
        if b == 0 { b = 10; }
        i64 v = 0;
        while true {
            i32 c = cast(i32, *p);
            i32 d = 0 - 1;
            if c >= 48 && c <= 57 { d = c - 48; }
            else if c >= 97 && c <= 122 { d = c - 97 + 10; }
            else if c >= 65 && c <= 90 { d = c - 65 + 10; }
            if d < 0 || cast(i64, d) >= b { break; }
            v = v * b + cast(i64, d);
            p = p + 1;
        }
        if endptr != null { *endptr = p; }
        return sign * v;
    }
}

// Allocator wrappers taken by address (spine's mallocFunc /
// reallocFunc / freeFunc hooks). Same shapes as cstdlib_shim.mc.
void* __tm_malloc(u64 n)           { return alloc(cast(i64, n)); }
void* __tm_realloc(void* p, u64 n) { return realloc(p, cast(i64, n)); }
void  __tm_free(void* p)           { free(p); }

// strrchr: last occurrence of byte c, or null (Atlas.c path split).
u8* strrchr(u8* s, i32 c) {
    u8* found = null;
    u8* p = s;
    while *p != 0 {
        if cast(i32, *p) == c { found = p; }
        p = p + 1;
    }
    if c == 0 { return p; }
    return found;
}

// isspace: C's " \t\n\v\f\r" set (Json.c whitespace skipping).
i32 isspace(i32 c) {
    if c == 32 || (c >= 9 && c <= 13) { return 1; }
    return 0;
}

// _stricmp: MSVC's case-insensitive strcmp (spine maps strcasecmp
// onto it under _MSC_VER).
i32 _stricmp(u8* a, u8* b) {
    while true {
        i32 ca = cast(i32, *a);
        i32 cb = cast(i32, *b);
        if ca >= 65 && ca <= 90 { ca = ca + 32; }
        if cb >= 65 && cb <= 90 { cb = cb + 32; }
        if ca != cb { return ca - cb; }
        if ca == 0 { return 0; }
        a = a + 1;
        b = b + 1;
    }
    return 0;
}

// strncat: append at most n bytes of src, always 0-terminate.
u8* strncat(u8* dst, u8* src, u64 n) {
    u8* d = dst;
    while *d != 0 { d = d + 1; }
    u64 i = 0;
    while i < n && *(src + i) != 0 {
        *d = *(src + i);
        d = d + 1;
        i = i + 1;
    }
    *d = 0;
    return dst;
}

// strtoul base-16 subset (Atlas.c color parsing: strtoul(s, &end, 16)).
u64 strtoul(u8* s, u8** endptr, i32 base) {
    u64 v = 0;
    u8* p = s;
    while *p == 32 || *p == 9 { p = p + 1; }
    while true {
        u8 ch = *p;
        u64 d = 0;
        if ch >= 48 && ch <= 57 { d = cast(u64, ch - 48); }
        else if base == 16 && ch >= 97 && ch <= 102 { d = cast(u64, ch - 87); }
        else if base == 16 && ch >= 65 && ch <= 70 { d = cast(u64, ch - 55); }
        else { break; }
        v = v * cast(u64, base) + d;
        p = p + 1;
    }
    if endptr != null { *endptr = p; }
    return v;
}

// spine-c support: the "%4x" scanner Json.c's unicode escapes use
// (spine_shim.h macros the sscanf call sites onto it).

i32 _sp_scan4x(u8* s, u32* out) {
    u32 v = 0;
    i32 n = 0;
    while n < 4 {
        u8 c = *(s + n);
        u32 d = 0;
        if c >= 48 && c <= 57 { d = c - 48; }
        else if c >= 97 && c <= 102 { d = c - 87; }
        else if c >= 65 && c <= 70 { d = c - 55; }
        else { break; }
        v = v * 16 + d;
        n++;
    }
    if n == 0 { return 0; }
    *out = v;
    return 1;
}

