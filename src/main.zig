const std = @import("std");
const ArrayList = std.ArrayList;
const print = std.debug.print;

const ComponentId = usize;

const Position = struct {
    x: f32,
    y: f32,
};

const Entity = struct {
    id: usize,
};

const Registry = struct {
    next_entity_id: usize,
    components: ArrayList(ComponentId),
    entities: ArrayList(Entity),

    pub fn init() Registry {
        return Registry{
            .next_entity_id = 0,
            .components = undefined,
            .entities = undefined,
        };
    }

    pub fn create_entity(self: *Registry) Entity {
        const entity_id = self.next_entity_id;
        self.next_entity_id += 1;

        const entity = Entity{ .id = entity_id };
        self.entities.append(entity);

        return entity;
    }

    pub fn add_component(self: *Registry, entity: Entity, component: Position) void {
        _ = component;

        const component_id = entity.id;
        self.components.append(component_id);
    }
};

pub fn main() void {
    const registry = Registry.init();

    //const entity = registry.create_entity();

    print("The next entity id is: {}\n", .{registry.next_entity_id});
}
